require 'gemjar/artifact'
require 'gemjar/artifact_builder'
require 'gemjar/logger'
require 'gemjar/task_executor'

module Gemjar
  class ArtifactRepository
    include Gemjar::Logger

    TASK_EXECUTOR = Gemjar::TaskExecutor.new 10

    def initialize directory
      @directory = directory
    end

    def ensure name, version
      log.info("Ensuring artifact #{name}-#{version} is installed.")
      find(name, version) || install(name, version)
    end

    def find name, version
      jar = "#@directory/#{name}-#{version}.jar"
      ivy = "#@directory/ivy-#{name}-#{version}.xml"
      if File.exists?(jar) && File.exists?(ivy)
        Artifact.new(jar, ivy).tap {|a| log.info("Found artifact #{name}-#{version}: #{a.inspect}")}
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
