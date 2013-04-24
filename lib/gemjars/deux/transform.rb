require 'pathname'
require 'gemjars/deux/zip'
require 'gemjars/deux/tar'
require 'gemjars/deux/pom'

module Gemjars
  module Deux
    class Transform
      def initialize name, version, io
        @name = name
        @version = version
        @io = io
      end

      def to_mvn specifications, &block
        handler = Handler.new(&block)

        jar_out = Java::JavaIo::ByteArrayOutputStream.new
        jar = ZipWriter.new(jar_out.to_io)
        pom_out = Java::JavaIo::ByteArrayOutputStream.new
        pom = pom_out.to_io

        visit Handler.new {|h|
          h.on_file {|name, content|
            jar.add_entry "gems/#@name-#@version/#{name}", content
          } 
          h.on_spec {|spec|
            if !spec.extensions.empty?
              handler.native spec.extensions
              return
            end
            jar.add_entry "specifications/#@name-#@version.gemspec", StringIO.new(spec.to_ruby_for_cache)
            Pom.new(spec).write_to(pom, specifications)
          }
          h.finish {
            jar.close
            pom.close

            jar_in = Java::JavaIo::ByteArrayInputStream.new(jar_out.to_byte_array)
            pom_in = Java::JavaIo::ByteArrayInputStream.new(pom_out.to_byte_array)

            handler.success jar_in.to_io, pom_in.to_io
          }
        }
      end

      private

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
        handler.finish
      end
    end

    class Handler
      def self.new &block
        handler_class = ::Class.new do
          class << self
            def method_missing name, *args, &block
              define_method(name) do |*args|
                block.call(*args).tap { @handled = true }
              end
            end
          end
          
          def handled?
            @handled || false
          end

          def unhandled?
            !handled?
          end
        end

        block.call handler_class

        class << handler_class
          undef method_missing
        end

        handler_class.new
      end
    end
  end
end

