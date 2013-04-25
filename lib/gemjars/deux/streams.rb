module Gemjars
  module Deux
    class Streams
      def self.read io
        out = StringIO.new
        while chunk = io.read(1024)
          out << chunk
        end
        out.string
      end

      def self.pipe
        pipe = Java::JavaNioChannels::Pipe.open
        r = Java::JavaNioChannels::Channels.new_input_stream(pipe.source).to_io
        w = Java::JavaNioChannels::Channels.new_output_stream(pipe.sink).to_io
        [r, w]
      end

      def self.pipe_channel
        pipe = Java::JavaNioChannels::Pipe.open
        [pipe.source, pipe.sink]
      end

      def self.to_channel stream
        Java::JavaNioChannels::Channels.new_channel(stream)
      end

      def self.to_input_stream channel
        Java::JavaNioChannels::Channels.new_input_stream(channel)
      end

      def self.to_output_stream channel
        Java::JavaNioChannels::Channels.new_output_stream(channel)
      end

      def self.read_channel channel
        buffer = Java::JavaNio::ByteBuffer.allocate(1024)
        out = Java::JavaIo::ByteArrayOutputStream.new
        out_channel = to_channel(out)

        copy_channel channel, out_channel
        
        String.from_java_bytes(out.to_byte_array)
      end

      def self.copy_channel channel_in, channel_out
        buffer = Java::JavaNio::ByteBuffer.allocate(1024)
        
        while channel_in.read(buffer) != -1
          buffer.flip
          channel_out.write buffer
          buffer.rewind
        end
      end
    end
  end
end
