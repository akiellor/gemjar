require 'gemjar/file_resource'

module Gemjar
  class Artifact
    def initialize paths
      @paths = paths
    end

    def jar
      FileResource.new(@paths.jar)
    end

    def ivy
      FileResource.new(@paths.ivy)
    end

    def pom
      FileResource.new(@paths.pom)
    end
  end
end