module Gemjars
  module Deux
    class Specification < Struct.new(:name, :version, :platform)
      def gem_uri
        if platform == "ruby"
          "http://rubygems.org/gems/#{name}-#{version}.gem"
        else
          "http://rubygems.org/gems/#{name}-#{version}-#{platform}.gem"
        end
      end

      def java?
        platform == "java"
      end

      def ruby?
        platform == "ruby"
      end

      def with_platform new_platform
        Specification.new(name, version, new_platform)
      end
    end
  end
end
