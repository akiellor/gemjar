require 'gemjar/gem'
require 'gemjar/logger'
require 'gemjar/artifact_builder'

module Gemjar
  class Artifact < Struct.new(:jar, :ivy)
    include Gemjar::Logger

    def self.ensure name, version
      log.info("Ensuring artifact #{name}-#{version} is installed.")
      Artifact.find(name, version) || Artifact.install(name, version)
    end

    def self.find name, version
      jar = "#{Gemjar::WORK_DIRECTORY}/#{name}-#{version}.jar"
      ivy = "#{Gemjar::WORK_DIRECTORY}/ivy-#{name}-#{version}.xml"
      if File.exists?(jar) && File.exists?(ivy)
        Artifact.new(jar, ivy).tap {|a| log.info("Found artifact #{name}-#{version}: #{a.inspect}")}
      end
    end

    def self.install name, version
      gem = Gem.install(name, version)
      gem and ArtifactBuilder.build(gem).tap {|a| log.info("Installed artifact: #{a.inspect}") }
    end
  end
end