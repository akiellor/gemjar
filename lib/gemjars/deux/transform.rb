require 'pathname'
require 'gemjars/deux/zip'
require 'gemjars/deux/tar'

module Gemjars
  module Deux
    class Gem
      def initialize io
        @io = io
      end

      def visit handler
        TarReader.new(@io).each do |gem_entry|
          if gem_entry.name == "data.tar.gz"
            TarReader.new(gem_entry.io, :gzip).each do |data_entry|
              handler.on_file data_entry.name, data_entry.io
            end
          end
          if gem_entry.name == "metadata.gz"
            handler.on_spec ::Gem::Specification.from_yaml(Java::JavaUtilZip::GZIPInputStream.new(Java::OrgJrubyUtil::IOInputStream.new(gem_entry.io)).to_io)
          end
        end
      end
    end

    class Handler
      def self.new &block
        handler_class = ::Class.new do
          class << self
            def method_missing name, *args, &block
              define_method(name) do |*args|
                block.call *args
              end
            end
          end
        end

        block.call handler_class

        class << handler_class
          undef method_missing
        end

        handler_class.new
      end
    end

    class Transform
      def self.apply name, version, gem_io, jar_io, pom_io, specs
        new(name, version, gem_io, jar_io, pom_io, specs).apply
     end

      def initialize name, version, gem_io, jar_io, pom_io, specs
        @name = name
        @version = version
        @gem_io = gem_io
        @jar_io = jar_io
        @pom_io = pom_io
        @specs = specs
      end

      def apply
        jar = ZipWriter.new(jar_io)
        
        gem = Gem.new(@gem_io)
        gem.visit Handler.new {|h|
          h.on_file {|name, content| jar.add_entry "gems/#@name-#@version/#{name}", content } 
          h.on_spec {|spec|
            jar.add_entry "specifications/#@name-#@version.gemspec", StringIO.new(spec.to_ruby_for_cache)
            Pom.new(spec).write_to(@pom_io, @specs)
          }
        }
      ensure
        jar.close
      end

      private

      attr_reader :gem_io, :jar_io
    end
  end
end

