require 'gemjars/deux/streams'
require 'gemjars/deux/specification'

module Gemjars
  module Deux
    class Specifications
      include Enumerable

      def self.rubygems http = Http.default
        http.get("http://rubygems.org/specs.4.8.gz") do |channel|
          input_stream = Streams.to_input_stream(channel)
          new Java::JavaUtilZip::GZIPInputStream.new(input_stream).to_io
        end
     end

      def initialize io
        @specs = {}
        Marshal.load(io).each do |spec|
          @specs[spec[0]] ||= []
          @specs[spec[0]] << Specification.new(spec[0], spec[1].to_s, spec[2])
        end
      end

      def [] name
        @specs[name]
      end

      def each
        @specs.each do |e|
          e[1].each do |j|
            yield j
          end
        end
      end

      def minimum_version name, specifier
        requirement = ::Gem::Requirement.new(specifier)
        self[name].
          select {|s| requirement.satisfied_by?(::Gem::Version.new(s.version)) }.
          sort_by {|s| ::Gem::Version.new(s.version) }.
          first.version
      end
    end
  end
end

