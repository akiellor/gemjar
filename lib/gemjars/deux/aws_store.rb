module Gemjars
  module Deux
    class AWSStore
      def initialize bucket
        @bucket = bucket
        @threads = []
      end

      def put name
        r, w = IO.pipe
        @threads << Thread.new {
          @bucket.objects.create name, r, :estimated_content_length => 2048 * 1024
        }
        w
      end

      def join
        @threads.each(&:join)
      end
    end
  end
end