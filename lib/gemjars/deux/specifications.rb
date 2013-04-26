require 'gemjars/deux/streams'
require 'gemjars/deux/specification'

module Gemjars
  module Deux
    class Specifications
      include Enumerable

      def self.rubygems http = Http.default
        http.get("http://rubygems.org/specs.4.8.gz") do |channel|
          from_gzip channel
        end
      end

      def self.prerelease_rubygems http = Http.default
        http.get("http://rubygems.org/prerelease_specs.4.8.gz") do |channel|
          from_gzip channel
        end
      end

      def self.from_gzip channel
        input_stream = Streams.to_input_stream(channel)
        gunzip_channel = Streams.to_channel(Java::JavaUtilZip::GZIPInputStream.new(input_stream))
        from_channel gunzip_channel 
      end

      def self.from_channel channel
        new Marshal.load(Streams.to_input_stream(channel).to_io)
      end

      def initialize specs
        @specs = {}
        specs.each do |spec|
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

