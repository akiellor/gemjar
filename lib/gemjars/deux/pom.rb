require 'builder'
require 'gemjars/deux/streams'

module Gemjars
  module Deux
    class Pom
      def self.to_maven_version name, version, specs
        specs.minimum_version name, version
      end

      def initialize spec, specifications
        @spec = spec
        @specifications = specifications
      end

      def unsatisfied_dependencies
        @spec.runtime_dependencies.
          reject {|dep| Pom.to_maven_version(dep.name, dep.requirement.as_list, @specifications) }.
          map {|dep| [dep.name, dep.requirement.as_list]}
      end

      def channel
        Streams.to_channel(Java::JavaIo::ByteArrayInputStream.new(to_xml.to_java_bytes))
      end

      private

      def to_xml
        io = StringIO.new
        xml = Builder::XmlMarkup.new :target => io
        xml.instruct!
        xml.project :xmlns => "http://maven.apache.org/POM/4.0.0" do |project|
          project.modelVersion "4.0.0"
          project.groupId "org.rubygems"
          project.artifactId @spec.name
          project.version @spec.version.to_s

          project.dependencies do |deps_node|
            @spec.runtime_dependencies.each do |dep|
              deps_node.dependency do |dependency_node|
                dependency_node.groupId "org.rubygems"
                dependency_node.artifactId dep.name
                dependency_node.version Pom.to_maven_version(dep.name, dep.requirement.as_list, @specifications)
              end
            end
          end
        end
        io.string
      end
    end
  end
end

