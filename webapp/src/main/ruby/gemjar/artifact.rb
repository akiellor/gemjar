require 'gemjar/artifact_repository'
require 'gemjar/logger'

module Gemjar
  class Artifact < Struct.new(:jar, :ivy)
    include Gemjar::Logger

    def self.ensure name, version
      log.info("Ensuring artifact #{name}-#{version} is installed.")
      Artifact.find(name, version) || Artifact.install(name, version)
    end

    def self.find name, version
      ArtifactRepository.new(Gemjar::WORK_DIRECTORY).find name, version
    end

    def self.install name, version
      ArtifactRepository.new(Gemjar::WORK_DIRECTORY).install name, version
    end
  end
end