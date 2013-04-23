require 'net/http'

module Gemjars
  module Deux
    class Http
      def self.single_threaded
        new Java::JavaUtilConcurrent::Executors.new_single_thread_executor
      end

      def self.default
        new Java::JavaUtilConcurrent::Executors.new_fixed_thread_pool(10)
      end

      def initialize executor
        @executor = executor
      end

      def get uri
        pipe = Java::JavaNioChannels::Pipe.open
        r = Java::JavaNioChannels::Channels.new_input_stream(pipe.source).to_io
        w = Java::JavaNioChannels::Channels.new_output_stream(pipe.sink)

        @executor.submit {
          internal_get(URI.parse(uri), w)
        }

        r
      end

      def internal_get uri, io
        begin
          Net::HTTP.get_response(uri) do |res|
            if res.code.to_i == 301 || res.code.to_i == 302
              return internal_get(URI.parse(res.header['location']), io)
            else
              res.read_body do |chunk|
                io.write chunk.to_java_bytes
              end
            end
          end
        rescue => e
          puts e
          puts e.backtrace
        ensure
          io.close
        end
      end
    end
  end
end

