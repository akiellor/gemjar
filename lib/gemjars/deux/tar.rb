module Gemjars
  module Deux
    class TarEntry
      CHUNK_SIZE = 2048
      
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

    class TarReader
      CHUNK_SIZE = 2048
      
      include Enumerable
      
      def initialize io, compression = :none
        @stream = Java::OrgKamranzafarJtar::TarInputStream.new(to_input_stream(compression, io))
      end

      def each
        while entry = @stream.next_entry
          yield TarEntry.new(entry.name, read_entry)
        end
      end

      private

      def read_entry
        tmp = Java::byte[CHUNK_SIZE].new
        out = Java::JavaIo::ByteArrayOutputStream.new
        while (bytes_read = @stream.read(tmp, 0, CHUNK_SIZE)) != -1
          out.write tmp, 0, bytes_read
        end

        Java::JavaIo::ByteArrayInputStream.new(out.to_byte_array).to_io
      end

      def to_input_stream compression, io
        send :"to_#{compression}_compression_stream", io
      end

      def to_none_compression_stream io
        Java::OrgJrubyUtil::IOInputStream.new(io)
      end

      def to_gzip_compression_stream io
        Java::JavaUtilZip::GZIPInputStream.new(to_none_compression_stream(io))
      end
    end
  end
end
