require 'gemjar/file_resource'

module Gemjar
  class Artifact
    def initialize jar_path, ivy_path, pom_path
      @jar_path = jar_path
      @ivy_path = ivy_path
      @pom_path = pom_path
    end

    def jar
      FileResource.new(@jar_path)
    end

    def ivy
      FileResource.new(@ivy_path)
    end

    def pom
      FileResource.new(@pom_path)
    end
  end
end