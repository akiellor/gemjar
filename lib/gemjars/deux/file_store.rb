require 'pathname'

module Gemjars
  module Deux
    class FileStore
      def initialize dir
        @dir = dir
      end

      def put name, opts = {}
        path = Pathname.new(File.expand_path(name, @dir))
        path.parent.mkpath
        path.open("w+")
      end
    end
  end
end
