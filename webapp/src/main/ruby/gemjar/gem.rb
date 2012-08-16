require 'builder'
require 'rubygems/specification'
require 'gemjar/gem_repository'

module Gemjar
  class Gem
    def self.install name, version
      ::Gem.configuration.verbose = true

      GemRepository.new.install name, version
    end

    attr_reader :installed_dir, :name, :version

    def initialize installed_dir, name, version
      @installed_dir = installed_dir
      @name = name
      @version = version
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
              deps.dependency :org => 'org.rubygems', :name => dep[:name], :rev => dep[:version].to_s
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
        {:name => spec[0][0], :version => spec[0][1]}
      end
    end
  end
end