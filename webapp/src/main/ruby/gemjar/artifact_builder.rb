require 'gemjar/artifact'
require 'gemjar/artifact_paths'
require 'fileutils'

module Gemjar
  class ArtifactBuilder
    def initialize directory
      @directory = directory
    end

    def build gem
      paths = ArtifactPaths.new @directory, gem.name, gem.version
      FileUtils.rm_rf [File.expand_path("cache", gem.installed_dir)]
      FileUtils.rm paths.jar, :force => true

      paths.open_ivy {|i| i.write gem.ivy_module_xml }
      paths.open_pom { |p| p.write(gem.pom_xml) }
      paths.open_jar do |zipfile|
        Dir["#{gem.installed_dir}/**/**"].each do |file|
          zipfile.add(file.sub(gem.installed_dir+'/', ''), file)
        end
      end

      Artifact.new(paths)
    end
  end
end

