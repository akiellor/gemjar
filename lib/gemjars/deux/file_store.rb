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

      def get name
        path = Pathname.new(File.expand_path(name, @dir))
        if path.file?
          path.open
        else
          nil
        end
      end
    end
  end
end
