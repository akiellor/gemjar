require 'gemjar/artifact_repository'
require 'gemjar/logger'
require 'gemjar/file_resource'

module Gemjar
  class Artifact
    include Gemjar::Logger

    def self.ensure name, version
      log.info("Ensuring artifact #{name}-#{version} is installed.")
      artifact_repository = ArtifactRepository.new(Gemjar::WORK_DIRECTORY)
      artifact_repository.find(name, version) || artifact_repository.install(name, version)
    end

    def initialize jar_path, ivy_path
      @jar_path = jar_path
      @ivy_path = ivy_path
    end

    def jar
      FileResource.new(@jar_path)
    end

    def ivy
      FileResource.new(@ivy_path)
    end
  end
end