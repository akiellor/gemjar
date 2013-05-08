require 'pathname'
require 'gemjars/deux/zip'
require 'gemjars/deux/tar'
require 'gemjars/deux/pom'
require 'gemjars/deux/binscript'

module Gemjars
  module Deux
    class Transform
      def initialize spec, channel
        @spec = spec
        @channel = channel
      end

      def to_mvn specifications, &block
        handler = Handler.new(&block)

        jar_out = Java::JavaIo::ByteArrayOutputStream.new
        jar = ZipWriter.new(Streams.to_channel(jar_out))

        pom = nil

        visit Handler.new {|h|
          h.on_file {|name, content|
            jar.add_entry "gems/#{@spec.identifier}/#{name}", content
          } 
          h.on_spec {|spec|
            if !spec.extensions.empty?
              handler.native spec.extensions
              return
            end
            jar.add_entry "specifications/#{@spec.identifier}.gemspec", Streams.to_channel(Java::JavaIo::ByteArrayInputStream.new(spec.to_ruby_for_cache.to_java_bytes))

            pom = Pom.new(spec, specifications)

            unsatisfied_deps = pom.unsatisfied_dependencies
            unless unsatisfied_deps.empty?
              handler.unsatisfied_dependencies unsatisfied_deps
              return
            end

            spec.executables && spec.executables.each do |executable|
              binscript = Binscript.new(spec, executable)
              jar.add_entry "bin/#{executable}", Streams.to_channel(Java::JavaIo::ByteArrayInputStream.new(binscript.to_s.to_java_bytes))
            end
          }
          h.finish {
            jar.close

            jar_in = Java::JavaIo::ByteArrayInputStream.new(jar_out.to_byte_array)

            handler.success Streams.to_channel(jar_in), pom
          }
        }
      end

      private

      def visit handler
        TarReader.new(@channel).each do |gem_entry|
          if gem_entry.name == "data.tar.gz"
            TarReader.new(gem_entry.channel, :gzip).each do |data_entry|
              handler.on_file data_entry.name, data_entry.channel
            end
          end
          if gem_entry.name == "metadata.gz"
            handler.on_spec ::Gem::Specification.from_yaml(Java::JavaUtilZip::GZIPInputStream.new(Streams.to_input_stream(gem_entry.channel)).to_io)
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

