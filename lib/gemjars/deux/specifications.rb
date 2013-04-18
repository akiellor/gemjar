module Gemjars
  module Deux
    class Specifications
      include Enumerable

      def initialize io
        @specs = {}
        Marshal.load(io).each do |spec|
          @specs[spec[0]] ||= []
          @specs[spec[0]] << spec[1].to_s
        end
      end

      def [] name
        @specs[name]
      end

      def each
        @specs.each do |e|
          e[1].zip([e[0]] * e[1].size).map(&:reverse).each do |j|
            yield j
          end
        end
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

