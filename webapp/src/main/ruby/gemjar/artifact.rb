require 'gemjar/gem'
require 'gemjar/logger'
require 'gemjar/artifact_builder'
require 'gemjar/artifact_repository'
require 'gemjar/task_executor'

module Gemjar
  class Artifact < Struct.new(:jar, :ivy)
    include Gemjar::Logger

    TASK_EXECUTOR = Gemjar::TaskExecutor.new 10

    def self.ensure name, version
      log.info("Ensuring artifact #{name}-#{version} is installed.")
      Artifact.find(name, version) || Artifact.install(name, version)
    end

    def self.find name, version
      ArtifactRepository.new(Gemjar::WORK_DIRECTORY).find name, version
    end

    def self.install name, version
      future = TASK_EXECUTOR.get_or_submit_task "#{name}-#{version}" do
        begin
          log.info("Installing artifact: '#{name}-#{version}'")
          gem = Gem.install(name, version)

          ArtifactBuilder.new(Gemjar::WORK_DIRECTORY).build(gem).tap do |a|
            log.info("Retrieved artifact: #{a.inspect}")
          end
        rescue => e
          log.error("Failed to retrieve artifact: #{name}-#{version}'", e)
          nil
        end
      end

      future.get
    end
  end
end