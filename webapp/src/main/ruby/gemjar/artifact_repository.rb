require 'gemjar/logger'

module Gemjar
  class ArtifactRepository
    include Gemjar::Logger

    def initialize directory
      @directory = directory
    end

    def find name, version
      jar = "#@directory/#{name}-#{version}.jar"
      ivy = "#@directory/ivy-#{name}-#{version}.xml"
      if File.exists?(jar) && File.exists?(ivy)
        Artifact.new(jar, ivy).tap {|a| log.info("Found artifact #{name}-#{version}: #{a.inspect}")}
      end
    end
  end
end
