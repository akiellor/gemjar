require 'gemjar/gem'
require 'gemjar/artifact_builder'

module Gemjar
  class Artifact < Struct.new(:jar, :ivy)
    def self.ensure name, version
      Artifact.find(name, version) || Artifact.install(name, version)
    end

    def self.find name, version
      jar = "#{Gemjar::WORKDIR}/#{name}-#{version}.jar"
      ivy = "#{Gemjar::WORKDIR}/ivy-#{name}-#{version}.xml"
      if File.exists?(jar) && File.exists?(ivy)
        Artifact.new jar, ivy
      end
    end

    def self.install name, version
      gem = Gem.install(name, version)
      gem and ArtifactBuilder.build(gem)
    end
  end
end