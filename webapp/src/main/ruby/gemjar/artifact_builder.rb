require 'gemjar/artifact'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'fileutils'

module Gemjar
  class ArtifactBuilder
    def initialize directory
      @directory = directory
    end

    def build gem
      ivy_path = "#@directory/ivy-#{gem.name}-#{gem.version}.xml"
      File.open(ivy_path, 'w+') { |f| f.write(gem.ivy_module_xml) }

      pom_path = "#@directory/pom-#{gem.name}-#{gem.version}.xml"
      File.open(pom_path, 'w+') { |f| f.write(gem.pom_xml) }

      jar_path = "#@directory/#{gem.name}-#{gem.version}.jar"
      FileUtils.rm_rf [File.expand_path("cache", gem.installed_dir)]

      FileUtils.rm jar_path, :force => true

      Zip::ZipFile.open(jar_path, 'w') do |zipfile|
        Dir["#{gem.installed_dir}/**/**"].reject { |f| f==jar_path }.each do |file|
          zipfile.add(file.sub(gem.installed_dir+'/', ''), file)
        end
      end

      Artifact.new(jar_path, ivy_path, pom_path)
    end
  end
end

