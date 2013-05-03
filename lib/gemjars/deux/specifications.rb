require 'set'
require 'gemjars/deux/streams'
require 'gemjars/deux/specification'

module Gemjars
  module Deux
    class Specifications
      include Enumerable

      attr_reader :size

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
        @size = specs.size
        specs.each do |spec|
          @specs[spec[0]] ||= Set.new
          group = @specs[spec[0]]
          specification = Specification.new(spec[0], spec[1].to_s, spec[2])

          if specification.ruby? && !group.include?(specification.with_platform("java"))
            group << specification
          end
          if specification.java?
            group.delete specification.with_platform("ruby")
            group << specification
          end
        end
      end

      def + other
        Specifications.new(other.to_a + self.to_a)
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

      def satisfactory_spec name, specifier
        requirement = ::Gem::Requirement.new(specifier)
        self[name] && self[name].
          select {|s| requirement.satisfied_by?(::Gem::Version.new(s.version)) }.
          sort_by {|s| ::Gem::Version.new(s.version) }.
          first
      end

      def number_of_releases name
        (@specs[name] || []).size
      end

      def == other
        Set.new(self.to_a) == Set.new(other.to_a)
      end
    end
  end
end

