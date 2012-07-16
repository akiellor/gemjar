require 'builder'
require 'fileutils'
require 'gemjar/dependency'
require 'rubygems/specification'
require 'rubygems/dependency_installer'

module Gemjar
  class Gem < Struct.new(:installed_dir, :name, :version)
    def self.install name, version
      ::Gem.configuration.verbose = true
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
end