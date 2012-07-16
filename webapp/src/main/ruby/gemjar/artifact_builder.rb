require 'gemjar/artifact'

module Gemjar
  class ArtifactBuilder
    def self.build gem
      FileUtils.cd gem.installed_dir do
        ivy_path = "#{Gemjar::WORKDIR}/ivy-#{gem.name}-#{gem.version}.xml"
        File.open(ivy_path, 'w+') { |f| f.write(gem.ivy_module_xml) }
        jar_path = "#{Gemjar::WORKDIR}/#{gem.name}-#{gem.version}.jar"
        FileUtils.rm_rf [File.expand_path("cache", gem.installed_dir)]
        if system("zip -r #{jar_path} *")
          return Artifact.new jar_path, ivy_path
        end
      end
    end
  end
end

