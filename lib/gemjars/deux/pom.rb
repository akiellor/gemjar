require 'builder'

module Gemjars
  module Deux
    class Pom
      def initialize spec
        @spec = spec
      end

      def write_to io
        xml = Builder::XmlMarkup.new :target => io
        xml.instruct!
        xml.project :xmlns => "http://maven.apache.org/POM/4.0.0" do |project|
          project.modelVersion "4.0.0"
          project.groupId "org.rubygems"
          project.artifactId @spec.name
          project.version @spec.version.to_s
        end
      end
    end
  end
end

