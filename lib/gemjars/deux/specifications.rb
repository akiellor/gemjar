module Gemjars
  module Deux
    class Specifications
      def initialize io
        @specs = Hash.new([])
        Marshal.load(io).each do |spec|
          @specs[spec[0]] << spec[1].to_s
        end
      end

      def [] name
        @specs[name]
      end
    end
  end
end

