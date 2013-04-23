require 'gemjars/deux/specification'

module Gemjars
  module Deux
    class Specifications
      include Enumerable

      def self.rubygems http = Http.default
        input_stream = Java::OrgJrubyUtil::IOInputStream.new(http.get("http://rubygems.org/specs.4.8.gz"))
        new Java::JavaUtilZip::GZIPInputStream.new(to_none_compression_stream(input_stream)).to_io
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

