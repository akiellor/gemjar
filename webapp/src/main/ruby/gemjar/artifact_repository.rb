require 'gemjar/artifact'
require 'gemjar/artifact_builder'
require 'gemjar/task_executor'
require 'gemjar/artifact_paths'

require 'method_decorators'
require 'gemjar/logged'

module Gemjar
  class ArtifactRepository
    extend MethodDecorators

    TASK_EXECUTOR = Gemjar::TaskExecutor.new(10).tap {|e| at_exit { e.destroy! } }

    def initialize directory
      @directory = directory
    end

    +Logged.new
    def ensure name, version
      find(name, version) || install(name, version)
    end

    +Logged.new
    def find name, version
      paths = ArtifactPaths.new @directory, name, version
      Artifact.new(paths) if paths.exist?
    end

    +Logged.new
    def install name, version
      future = TASK_EXECUTOR.get_or_submit_task "#{name}-#{version}" do
        gem = Gem.install(name, version)

        ArtifactBuilder.new(@directory).build(gem)
      end

      future.get
    rescue ExecutionException => e
      raise e.cause
    end
  end
end
