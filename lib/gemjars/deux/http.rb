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
        r, w = IO.pipe

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
                io << chunk
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

