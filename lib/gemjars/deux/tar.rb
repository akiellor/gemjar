module Gemjars
  module Deux
    class TarEntry
      attr_reader :name
      
      def initialize name
        @name = name
      end
    end

    class TarReader
      include Enumerable
      
      def initialize io, compression = :none
        @stream = Java::OrgKamranzafarJtar::TarInputStream.new(to_input_stream(compression, io))
      end

      def each
        while entry = @stream.next_entry
          yield TarEntry.new(entry.name)
        end
      end

      private

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
