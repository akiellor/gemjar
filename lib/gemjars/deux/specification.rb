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
    end
  end
end
