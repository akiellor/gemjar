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
          reader = Java::JavaIo::BufferedReader.new(Java::JavaIo::InputStreamReader.new(Streams.to_input_stream(Streams.to_gzip_read_channel(channel))))
          while definition_json = reader.read_line
            yield MultiJson.load(definition_json, :symbolize_keys => true)
          end
        end
      end

      class Out
        def initialize store
          @store = store
          @out = Streams.to_gzip_write_channel(@store.put("index"))
        end

        def << definition
          @out.write Streams.to_buffer(MultiJson.dump(definition) + "\n")
        end

        def close
          @out.close
        end
      end

      def initialize store, *metadata_indexes
        @store = store
        @hashes = Set.new
        @index = Set.new
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
        out = Out.new(@store)
        @index.each {|d| out << d }
      ensure
        out.close if out
      end

      def load_index
        @in.each do |definition|
          inner_add definition
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

      def to_spec definition
        Specification.new(definition[:spec][:name], definition[:spec][:version], definition[:spec][:platform])
      end
    end
  end
end

