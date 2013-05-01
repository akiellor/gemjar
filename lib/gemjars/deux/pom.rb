require 'builder'
require 'gemjars/deux/streams'

module Gemjars
  module Deux
    class Pom
      def initialize spec, specifications
        @spec = spec
        @specifications = specifications
      end

      def unsatisfied_dependencies
        @spec.runtime_dependencies.
          reject {|dep| @specifications.satisfactory_spec(dep.name, dep.requirement.as_list) }.
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
                dependency_node.version @specifications.satisfactory_spec(dep.name, dep.requirement.as_list).version
              end
            end
          end
        end
        io.string
      end
    end
  end
end

