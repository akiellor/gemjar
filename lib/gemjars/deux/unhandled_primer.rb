module Gemjars
  module Deux
    class UnhandledPrimer
      def initialize index
        @index = index
      end

      def prime specs, queue
        specs.each {|s| queue << s unless @index.handled?(s) }
      end
    end
  end
end

