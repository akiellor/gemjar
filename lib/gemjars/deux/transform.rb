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
              jar.add_entry "gems/#@name-#@version/" + data_entry.name
            end
          end
        end
      ensure
        jar_io.close
        gem_io.close
      end

      private

      attr_reader :gem_io, :jar_io
    end
  end
end

