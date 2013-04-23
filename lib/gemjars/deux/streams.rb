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
    end
  end
end
