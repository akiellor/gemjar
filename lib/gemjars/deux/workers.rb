require 'timeout'

module Gemjars
  module Deux
    class Workers
      TIMEOUT_PER_WORKER = 3
      WAIT_DELAY = 0.2

      def initialize queue, workers
        @queue = queue
        @workers = workers
      end

      def halt!
        drain
        await_workers
      end

      def run!
        @workers.each {|w| w.async.run }
        @workers.each {|w| w.thread.join }
      end

      private

      def await_workers
        Timeout::timeout(@workers.size * TIMEOUT_PER_WORKER) do
          until @workers.all?(&:done?)
            sleep WAIT_DELAY
          end
        end
      end

      def drain
        until @queue.empty?
          @queue.pop
        end
      end
    end
  end
end
