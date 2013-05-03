module Gemjars
  module Deux
    class SpecifiedPrimer
      def initialize gem_names
        @gem_names = gem_names
      end

      def prime specs, queue
        specs.each {|s| queue << s if @gem_names.include?(s.name) }
      end
    end
  end
end

