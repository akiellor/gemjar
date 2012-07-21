require 'gemjar/gem'
require 'gemjar/logger'
require 'gemjar/artifact_builder'

module Gemjar
  class Artifact < Struct.new(:jar, :ivy)
    include Gemjar::Logger

    def self.executor
      @executor ||= Java::java.util.concurrent.Executors.newFixedThreadPool(10)
    end

    def self.tasks
      @tasks ||= Java::java.util.concurrent.ConcurrentHashMap.new
    end

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
      task = java.util.concurrent.FutureTask.new proc {
        begin
          log.info("Installing artifact: '#{name}-#{version}'")
          gem = Gem.install(name, version)
          gem and ArtifactBuilder.build(gem)
        rescue => e
          nil
        end
      }

      future = get_or_submit_task "#{name}-#{version}", task

      future.get.tap {|a| log.info("Retrieved artifact: #{a.inspect}") }
    end

    def self.get_or_submit_task name, task
      self.tasks.synchronized do
        unless self.tasks.get(name)
          self.tasks.put name, task
          executor.execute(self.tasks.get(name))
        end
        self.tasks.get(name)
      end
    end
  end
end