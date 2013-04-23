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
        YAML.load(@store.get("index.yml"))
      end
    end
  end
end

