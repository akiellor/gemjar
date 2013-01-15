require 'zip/zip'
require 'zip/zipfilesystem'

module Gemjar
  class ArtifactPaths
    attr_reader :jar, :ivy, :pom

    def initialize directory, name, version
      @jar = "#{directory}/#{name}-#{version}.jar"
      @ivy = "#{directory}/ivy-#{name}-#{version}.xml"
      @pom = "#{directory}/pom-#{name}-#{version}.xml"
    end

    def open_jar &block
      Zip::ZipFile.open(@jar, 'w', &block)
    end

    def open_ivy &block
      File.open(@ivy, 'w+', &block)
    end

    def open_pom &block
      File.open(@pom, 'w+', &block)
    end
  end
end
