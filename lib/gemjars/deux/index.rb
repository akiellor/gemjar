require 'gson'
require 'multi_json'
require 'thread'
require 'set'
require 'digest/md5'

module Gemjars
  module Deux
    class Index
      include Enumerable

      class In
        include Enumerable

        def initialize store
          @store = store
        end

        def each
          channel = @store.get("index")
          return unless channel
          io = Streams.to_gzip_read_channel(channel).to_io
          while definition_json = io.gets
            yield to_spec_and_metadata(MultiJson.load(definition_json, :symbolize_keys => true))
          end
        end

        private

        def to_spec_and_metadata definition
          [Specification.new(definition[:spec][:name], definition[:spec][:version], definition[:spec][:platform]), definition[:metadata]]
        end
      end

      class Out
        def initialize store
          @store = store
          @out = Streams.to_gzip_write_channel(@store.put("index"))
        end

        def add spec, metadata
          @out.write Streams.to_buffer(MultiJson.dump(to_definition(spec, metadata)) + "\n")
        end

        def close
          @out.close
        end

        private

        def to_definition spec, metadata
          {:spec => {:name => spec.name, :version => spec.version, :platform => spec.platform}, :metadata => metadata}
        end
      end

      def initialize store, *metadata_indexes
        @store = store
        @index = Set.new
        @metadata = {}
        @metadata_indexes = Hash[metadata_indexes.map {|n| [n, Set.new] }]
        @mutex = Mutex.new
        @in = In.new(@store)
        load_index
      end

      def handled? spec
        include? spec
      end

      def add spec, metadata = {}
        @mutex.synchronize do
          inner_add spec, metadata

          if @index.size % 500 == 0
            flush_inner
          end
        end
      end

      def [] metadata_key
        @metadata_indexes[metadata_key]
      end

      def include? spec
        @mutex.synchronize do
          @index.include?(spec)
        end
      end

      def each
        @mutex.synchronize do
          @index.each {|s| yield s }
        end
      end

      def delete_all specs
        @mutex.synchronize do
          specs.each do |spec|
            @index.delete(spec)
            @metadata.delete(spec)
          end

          flush_inner
        end
      end

      def flush
        @mutex.synchronize { flush_inner }
      end

      private

      def flush_inner
        out = Out.new(@store)
        @index.each {|spec| out.add spec, @metadata[spec] }
      ensure
        out.close if out
      end

      def load_index
        @in.each do |spec, metadata|
          inner_add spec, metadata
        end
      end

      def inner_add spec, metadata
        metadata.each do |k, v|
          if @metadata_indexes.has_key?(k)
            @metadata_indexes[k] << spec
          end
        end
        @metadata[spec] = metadata
        @index << spec
      end
    end
  end
end

