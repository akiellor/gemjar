require 'gemjars/deux/streams'

module Gemjars
  module Deux
    class TarEntry
      CHUNK_SIZE = 2048
      
      attr_reader :name, :channel
      
      def initialize name, channel
        @name = name
        @channel = channel
      end

      def read
        Streams.read_channel(channel)
      end
    end

    class TarReader
      CHUNK_SIZE = 2048
      
      include Enumerable
      
      def initialize channel, compression = :none
        @stream = Java::OrgKamranzafarJtar::TarInputStream.new(to_input_stream(compression, channel))
      end

      def each
        while entry = @stream.next_entry
          yield TarEntry.new(entry.name, read_entry)
        end
      end

      private

      def read_entry
        Streams.to_channel(@stream)
      end

      def to_input_stream compression, channel
        send :"to_#{compression}_compression_stream", channel
      end

      def to_none_compression_stream channel
        Streams.to_input_stream(channel)
      end

      def to_gzip_compression_stream channel
        Java::JavaUtilZip::GZIPInputStream.new(to_none_compression_stream(channel))
      end
    end
  end
end
