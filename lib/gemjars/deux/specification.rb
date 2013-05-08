module Gemjars
  module Deux
    class Specification < Struct.new(:name, :version, :platform)
      def gem_uri
        "http://rubygems.org/gems/#{identifier}.gem"
      end

      def identifier
        if ruby?
          "#{name}-#{version}"
        else
          "#{name}-#{version}-#{platform}"
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
