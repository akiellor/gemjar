module Gemjar
  class ArtifactPaths
    attr_reader :jar, :ivy, :pom

    def initialize directory, name, version
      @jar = "#{directory}/#{name}-#{version}.jar"
      @ivy = "#{directory}/ivy-#{name}-#{version}.xml"
      @pom = "#{directory}/pom-#{name}-#{version}.xml"
    end
  end
end