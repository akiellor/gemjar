require 'pathname'
require 'gemjars/deux/zip'
require 'gemjars/deux/tar'

module Gemjars
  module Deux
    class Transform
      def self.apply name, version, gem_io, jar_io
        new(name, version, gem_io, jar_io).apply
     end

      def initialize name, version, gem_io, jar_io
        @name = name
        @version = version
        @gem_io = gem_io
        @jar_io = jar_io
      end

      def apply
        jar = ZipWriter.new(jar_io)
        TarReader.new(gem_io).each do |gem_entry|
          if gem_entry.name == "data.tar.gz"
            TarReader.new(gem_entry.io, :gzip).each do |data_entry|
              jar.add_entry "gems/#@name-#@version/#{data_entry.name}", data_entry.io
            end
          end
          if gem_entry.name == "metadata.gz"
            spec = Gem::Specification.from_yaml(Java::JavaUtilZip::GZIPInputStream.new(Java::OrgJrubyUtil::IOInputStream.new(gem_entry.io)).to_io)
            jar.add_entry "specifications/#@name-#@version.gemspec", StringIO.new(spec.to_ruby_for_cache)
          end
        end
      ensure
        jar.close
      end

      private

      attr_reader :gem_io, :jar_io
    end
  end
end

