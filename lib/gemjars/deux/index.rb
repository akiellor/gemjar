require 'gson'
require 'multi_json'
require 'thread'
require 'set'
require 'digest/md5'

module Gemjars
  module Deux
    class Index
      include Enumerable

      def initialize store, *metadata_indexes
        @store = store
        @hashes = Set.new
        @index = Set.new
        @metadata_indexes = Hash[metadata_indexes.map {|n| [n, Set.new] }]
        @mutex = Mutex.new
        load_index
      end

      def handled? spec
        include? spec
      end

      def add spec, metadata = {}
        @mutex.synchronize do
          inner_add :spec => {:name => spec.name, :version => spec.version, :platform => spec.platform},
            :metadata => metadata

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
          @hashes.include?(spec.signature)
        end
      end

      def each
        @mutex.synchronize do
          @index.each {|h| yield to_spec(h) }
        end
      end

      def delete_all specs
        @mutex.synchronize do
          to_delete = @index.select do |definition|
            specs.include?(to_spec(definition))
          end

          to_delete.each do |definition|
            inner_delete definition
          end

          flush_inner
        end
      end

      def flush
        @mutex.synchronize { flush_inner }
      end

      private

      def flush_inner
        out = Streams.to_gzip_write_channel(@store.put("index"))
        out.write Streams.to_buffer(MultiJson.dump(@index.to_a))
      ensure
        out.close if out
      end

      def load_index
        io = @store.get("index")
        if io
          MultiJson.load(Streams.read_channel(Streams.to_gzip_read_channel(io)), :symbolize_keys => true).each do |definition|
            inner_add definition
          end
        end
      end

      def inner_add definition
        definition[:metadata].each do |k, v|
          if @metadata_indexes.has_key?(k)
            @metadata_indexes[k] << to_spec(definition)
          end
        end
        @index << definition
        @hashes << to_spec(definition).signature
      end

      def inner_delete definition
        @index.delete definition
        @hashes.delete to_spec(definition).signature
      end

      private

      def to_spec definition
        Specification.new(definition[:spec][:name], definition[:spec][:version], definition[:spec][:platform])
      end
    end
  end
end

