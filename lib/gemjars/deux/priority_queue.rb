module Gemjars
  module Deux
    class PriorityQueue
      class Entry
        include Java::JavaLang::Comparable

        attr_reader :spec, :priority

        def initialize spec, priority
          @spec = spec
          @priority = priority
        end

        def compare_to other
          comp = other.priority.to_i <=> @priority.to_i
          comp.zero? ? (::Gem::Version.new(other.spec.version) <=> ::Gem::Version.new(@spec.version)) : comp
        end
      end

      def initialize specifications
        @specifications = specifications
        @queue = Java::JavaUtilConcurrent::PriorityBlockingQueue.new
      end

      def << spec
        @queue.offer Entry.new(spec, @specifications.number_of_releases(spec.name))
      end

      def pop
        e = @queue.poll
        e && e.spec
      end

      def empty?
        @queue.empty?
      end
    end
  end
end

