require 'yaml'
require 'celluloid'
require 'set'

module Gemjars
  module Deux
    class Index
      include Celluloid

      finalizer :flush

      def initialize store
        @store = store
        @index = load_index
      end

      def handled? spec
        @index.include?(spec)
      end

      def add spec
        @index << spec
        if @index.size % 500 == 0
          flush
        end
      end

      def flush
        out = @store.put("index.yml")
        out.write Streams.to_buffer(YAML.dump(@index))
      ensure
        out.close if out
      end

      private
      
      def load_index
        io = @store.get("index.yml")
        io ? Set.new(YAML.load(Streams.read_channel(io))) : Set.new
      end
    end
  end
end

