require 'gemjar/artifact'
require 'gemjar/artifact_builder'
require 'gemjar/logger'
require 'gemjar/task_executor'
require 'gemjar/artifact_paths'

module Gemjar
  class ArtifactRepository
    include Gemjar::Logger

    TASK_EXECUTOR = Gemjar::TaskExecutor.new(10).tap {|e| at_exit { e.destroy! } }

    def initialize directory
      @directory = directory
    end

    def ensure name, version
      log.info("Ensuring artifact #{name}-#{version} is installed.")
      find(name, version) || install(name, version)
    end

    def find name, version
      paths = ArtifactPaths.new @directory, name, version
      if paths.exist?
        Artifact.new(paths).tap {|a| log.info("Found artifact #{name}-#{version}: #{a.inspect}")}
      end
    end

    def install name, version
      future = TASK_EXECUTOR.get_or_submit_task "#{name}-#{version}" do
        begin
          log.info("Installing artifact: '#{name}-#{version}'")
          gem = Gem.install(name, version)

          ArtifactBuilder.new(@directory).build(gem).tap do |a|
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
