require 'gemjar/artifact'
require 'gemjar/logger'

module Gemjar
  class ArtifactBuilder
    def self.build gem
      FileUtils.cd gem.installed_dir do
        ivy_path = "#{Gemjar::WORK_DIRECTORY}/ivy-#{gem.name}-#{gem.version}.xml"
        File.open(ivy_path, 'w+') { |f| f.write(gem.ivy_module_xml) }
        jar_path = "#{Gemjar::WORK_DIRECTORY}/#{gem.name}-#{gem.version}.jar"
        FileUtils.rm_rf [File.expand_path("cache", gem.installed_dir)]

        require 'zip/zip'
        require 'zip/zipfilesystem'

        FileUtils.rm jar_path, :force => true

        Zip::ZipFile.open(jar_path, 'w') do |zipfile|
          Dir["#{gem.installed_dir}/**/**"].reject { |f| f==jar_path }.each do |file|
            zipfile.add(file.sub(gem.installed_dir+'/', ''), file)
          end
        end

        return Artifact.new jar_path, ivy_path
      end
    end
  end
end

