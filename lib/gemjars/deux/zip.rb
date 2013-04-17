module Gemjars
  module Deux
    class ZipEntry
      CHUNK_SIZE = 2024
      
      attr_reader :name, :io
      
      def initialize name, io
        @name = name
        @io = io
      end

      def read
        out = StringIO.new
        while chunk = io.read(CHUNK_SIZE)
          out << chunk
        end
        out.string
      end
    end

    class ZipReader
      CHUNK_SIZE = 2048
      
      include Enumerable

      def initialize io
        @stream = Java::JavaUtilZip::ZipInputStream.new(Java::OrgJrubyUtil::IOInputStream.new(io))
      end

      def each &block
        while entry = @stream.next_entry
          yield ZipEntry.new(entry.name, read(entry))
        end
      end

      private

      def read entry
        tmp = Java::byte[CHUNK_SIZE].new
        out = Java::JavaIo::ByteArrayOutputStream.new
        while (bytes_read = @stream.read(tmp, 0, CHUNK_SIZE)) != -1
          out.write tmp, 0, bytes_read
        end

        Java::JavaIo::ByteArrayInputStream.new(out.to_byte_array).to_io
      end
    end

    class ZipWriter
      CHUNK_SIZE = 2048
      
      def initialize io
        @stream = Java::JavaUtilZip::ZipOutputStream.new(Java::OrgJrubyUtil::IOOutputStream.new(io))
      end

      def add_entry name, io = StringIO.new
        @stream.put_next_entry Java::JavaUtilZip::ZipEntry.new(name)
        while chunk = io.read(CHUNK_SIZE)
          @stream.write chunk.to_java_bytes, 0, chunk.size
        end
        @stream.close_entry
      end

      def close
        @stream.finish
        @stream.flush
        @stream.close
      end
    end
  end
end
