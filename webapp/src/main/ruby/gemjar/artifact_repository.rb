require 'gemjar/artifact'
require 'gemjar/artifact_builder'
require 'gemjar/artifact_paths'

require 'method_decorators'
require 'gemjar/logged'
require 'thread'


module Gemjar
  class ArtifactRepository
    extend MethodDecorators

    SEMAPHORE = Mutex.new

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
      SEMAPHORE.synchronize do
        gem = Gem.install(name, version)

        ArtifactBuilder.new(@directory).build(gem)
      end
    end
  end
end
