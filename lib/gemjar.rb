require 'gemjar/version'
require 'sinatra/base'
require 'tmpdir'
require 'fileutils'
require 'rubygems/specification'
require 'rubygems/dependency_installer'
require 'builder'
require 'digest/md5'
require 'digest/sha1'

module RubyGems
  WORKDIR = "#{Dir.tmpdir}/gemjars" and FileUtils.mkdir_p(WORKDIR)

  class Gem < Struct.new(:installed_dir, :name, :version)
    def self.install name, version
      tmpdir = Dir.mktmpdir
      installer = ::Gem::DependencyInstaller.new :install_dir => "#{tmpdir}/gem_home", :ignore_dependencies => true
      installer.install name, version
      Gem.new "#{tmpdir}/gem_home", name, version
    end
    
    def ivy_module_xml
      cached_spec = spec
      "".tap do |out|
        xml = Builder::XmlMarkup.new :target => out
        xml.instruct!
        xml.tag!(:'ivy-module', {:version => '2.0'}) do |mod|
          mod.info({
            :organisation => "org.rubygems",
            :module => cached_spec.name,
            :revision => cached_spec.version.to_s,
            :status => "release",
            :publication => cached_spec.date.to_i * 1000})

          mod.configurations do |configs|
            configs.conf :name => "default", :visibility => "public"
          end

          mod.dependencies do |deps|
            dependencies.each do |dep|
              deps.dependency :org => 'org.rubygems', :name => dep.name, :rev => dep.version.to_s
            end
          end
        end
      end
    end

    private

    def spec
      if gemspec = Dir["#{installed_dir}/specifications/*.gemspec"].first
        ::Gem::Specification.load gemspec
      end
    end

    def dependencies
      deps = spec.runtime_dependencies
      deps.map do |dep|
        spec = ::Gem::SpecFetcher.new.find_matching(dep, true, false).first
        Dependency.new spec[0][0], spec[0][1]
      end
    end
  end

  class GemJarBuilder
    def self.build gem
      FileUtils.cd gem.installed_dir do
        ivy_path = "#{WORKDIR}/ivy-#{gem.name}-#{gem.version}.xml"
        File.open(ivy_path, 'w+') {|f| f.write(gem.ivy_module_xml) }
        jar_path = "#{WORKDIR}/#{gem.name}-#{gem.version}.jar"
        if system("zip -r #{jar_path} *")
          return GemJar.new jar_path, ivy_path
        end
      end
    end
  end

  class GemJar < Struct.new(:jar, :ivy)
    def self.ensure name, version
      GemJar.find(name, version) || GemJar.install(name, version)
    end

    def self.find name, version
      jar = "#{WORKDIR}/#{name}-#{version}.jar"
      ivy = "#{WORKDIR}/ivy-#{name}-#{version}.xml"
      if File.exists?(jar) && File.exists?(ivy)
        GemJar.new jar, ivy
      end
    end

    def self.install name, version
      gem = Gem.install(name, version)
      gem and GemJarBuilder.build(gem)
    end
  end
  
  class Dependency < Struct.new(:name, :version)
  end

  class App < Sinatra::Base
    before do
      expires (365 * 24 * 3600), :public
    end

    before('*.sha1') { content_type 'plain/text' }
    before('*.md5') { content_type 'plain/text' }
    before('*.xml') { content_type 'application/xml' }
    
    get "/jars/org.rubygems/:name-:version.jar" do |name, version|
      gem_jar = GemJar.ensure(name, version) or raise Sinatra::NotFound
      send_file gem_jar.jar, :filename => gem_jar.jar
    end

    get "/jars/org.rubygems/:name-:version.jar.sha1" do |name, version|
      gem_jar = GemJar.ensure(name, version) or raise Sinatra::NotFound
      body Digest::SHA1.file(gem_jar.jar).to_s
    end

    get "/jars/org.rubygems/:name-:version.jar.md5" do |name, version|
      gem_jar = GemJar.ensure(name, version) or raise Sinatra::NotFound
      body Digest::MD5.file(gem_jar.jar).to_s
    end

    get "/ivys/org.rubygems/ivy-:name-:version.xml" do |name, version|
      gem_jar = GemJar.ensure(name, version) or raise Sinatra::NotFound
      body File.read(gem_jar.ivy)
    end

    get "/ivys/org.rubygems/ivy-:name-:version.xml.sha1" do |name, version|
      gem_jar = GemJar.ensure(name, version) or raise Sinatra::NotFound
      body Digest::SHA1.file(gem_jar.ivy).to_s
    end
 
    get "/ivys/org.rubygems/ivy-:name-:version.xml.md5" do |name, version|
      gem_jar = GemJar.ensure(name, version) or raise Sinatra::NotFound
      body Digest::MD5.file(gem_jar.ivy).to_s
    end
  end
end

