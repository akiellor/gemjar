require 'gemjar/artifact'
require 'gemjar/artifact_paths'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'fileutils'

module Gemjar
  class ArtifactBuilder
    def initialize directory
      @directory = directory
    end

    def build gem
      paths = ArtifactPaths.new @directory, gem.name, gem.version
      File.open(paths.ivy, 'w+') { |f| f.write(gem.ivy_module_xml) }

      File.open(paths.pom, 'w+') { |f| f.write(gem.pom_xml) }

      FileUtils.rm_rf [File.expand_path("cache", gem.installed_dir)]

      FileUtils.rm paths.jar, :force => true

      Zip::ZipFile.open(paths.jar, 'w') do |zipfile|
        Dir["#{gem.installed_dir}/**/**"].reject { |f| f== paths.jar }.each do |file|
          zipfile.add(file.sub(gem.installed_dir+'/', ''), file)
        end
      end

      Artifact.new(paths)
    end
  end
end

