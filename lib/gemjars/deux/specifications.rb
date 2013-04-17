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

      def minimum_version name, specifier
        requirement = Gem::Requirement.new(specifier)
        self[name].
          select {|s| requirement.satisfied_by?(Gem::Version.new(s)) }.
          sort.
          first
      end
    end
  end
end

