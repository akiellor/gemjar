module Gemjars
  module Deux
    class ExactVersionPrimer
      def initialize gems
        @gems = gems
      end

      def prime specs, queue
        specs.each {|s| queue << s if @gems.include?([s.name, s.version])}
      end
    end
  end
end

