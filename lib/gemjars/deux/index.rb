require 'gson'
require 'multi_json'
require 'thread'
require 'set'
require 'digest/md5'

module Gemjars
  module Deux
    class Index
      def initialize store
        @store = store
        @hashes = Set.new
        @index = Set.new
        @mutex = Mutex.new
        load_index
      end

      def handled? spec
        @mutex.synchronize do
          @hashes.include?(signature(spec.name, spec.version, spec.platform))
        end
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

      def flush
        @mutex.synchronize { flush_inner }
      end

      private

      def flush_inner
        out = @store.put("index.json")
        out.write Streams.to_buffer(MultiJson.dump(@index.to_a))
      ensure
        out.close if out
      end

      def load_index
        io = @store.get("index.json")
        if io
          MultiJson.load(Streams.read_channel(io), :symbolize_keys => true).each do |definition|
            inner_add definition
          end
        end
      end

      def inner_add definition
        @index << definition
        @hashes << signature(definition[:spec][:name], definition[:spec][:version], definition[:spec][:platform])
      end

      def signature name, version, platform
        Digest::MD5.hexdigest("#{name}:#{version}:#{platform}")
      end
    end
  end
end

