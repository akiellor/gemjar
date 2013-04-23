require 'yaml'

module Gemjars
  module Deux
    class Index
      def initialize store
        @store = store
      end

      def handled? spec
        index.include?(spec)
      end

      def add spec
        new_index = index << spec
        out = @store.put("index.yml")
        out << YAML.dump(new_index)
      ensure
        out.close
      end

      private
      
      def index
        io = @store.get("index.yml")
        io ? YAML.load(io) : []
      end
    end
  end
end

