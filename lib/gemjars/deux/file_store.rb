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
        Java::JavaIo::FileOutputStream.new(path.to_s).channel
      end

      def get name
        path = Pathname.new(File.expand_path(name, @dir))
        if path.file?
          Java::JavaIo::FileInputStream.new(path.to_s).channel
        else
          nil
        end
      end

      def delete name
        path = Pathname.new(File.expand_path(name, @dir))
        if path.file?
          path.delete
        end
      end
    end
  end
end
