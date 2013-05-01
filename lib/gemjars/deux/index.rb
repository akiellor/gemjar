require 'yaml'
require 'celluloid'
require 'set'
require 'digest/md5'

module Gemjars
  module Deux
    class Index
      include Celluloid

      finalizer :flush

      def initialize store
        @store = store
        @hashes = Set.new
        @index = Set.new
        load_index
      end

      def handled? spec
        @hashes.include?(signature(spec.name, spec.version, spec.platform))
      end

      def add spec, metadata = {}
        inner_add :spec => {:name => spec.name, :version => spec.version, :platform => spec.platform},
                  :metadata => metadata

        if @index.size % 500 == 0
          flush
        end
      end

      def flush
        out = @store.put("index.yml")
        out.write Streams.to_buffer(YAML.dump(@index.to_a))
      ensure
        out.close if out
      end

      private
      
      def load_index
        io = @store.get("index.yml")
        if io
          YAML.load(Streams.read_channel(io)).each do |definition|
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

