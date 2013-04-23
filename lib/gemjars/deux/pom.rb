require 'builder'

module Gemjars
  module Deux
    class Pom
      def self.to_maven_version name, version, specs
        specs.minimum_version name, version
      end

      def initialize spec
        @spec = spec
      end

      def write_to io, specs
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
                dependency_node.version Pom.to_maven_version(dep.name, dep.requirement.as_list, specs)
              end
            end
          end
        end
      end
    end
  end
end

