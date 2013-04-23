require 'yaml'

module Gemjars
  module Deux
    class Index
      def initialize store
        @store = store
      end

      def handled? spec
        YAML.load(@store.get("index.yml")).include?(spec)
      end
    end
  end
end

