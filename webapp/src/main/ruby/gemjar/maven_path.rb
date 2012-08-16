module Gemjar
  class MavenPath
    def self.parse path
      parts = Parser.new(path).parts
      new parts[:organisation], parts[:artifact], parts[:version], parts[:extension]
    end

    attr_reader :organisation, :artifact, :version, :extension

    def initialize organisation, artifact, version, extension
      @organisation = organisation
      @artifact = artifact
      @version = version
      @extension = extension
    end

    class Parser
      END_OF_SEQUENCE = "$"

      SPLITS = [
        {:character => ".", :name => :extension},
        {:character => "-", :name => :version},
        {:character => "/", :name => :artifact},
        {:character => "/", :name => :version},
        {:character => "/", :name => :artifact},
        {:character => END_OF_SEQUENCE, :name => :organisation}
      ]

      def initialize path
        @split_index = 0
        @cursor = 0
        @content = path.reverse + END_OF_SEQUENCE
        @tokens = []
      end

      def parts
        parts = tokenize

        unless parts.size == 6
          raise "Should have exactly 6 tokens but had: #{parts.inspect}"
        end

        organisation, artifact1, version1, artifact2, version2, extension = parts

        unless [artifact1, version1] == [artifact2, version2]
          raise "The artifact parts in the path were in consistent. first: #{[artifact1, version1].inspect}, second: #{[artifact2, version2].inspect}"
        end

        {
          :organisation => organisation[1..-1].gsub("/", "."),
          :artifact => artifact1,
          :version => version1,
          :extension => extension
        }
      end

      def tokenize
        return @tokens unless @tokens.empty?
        while (token = next_token)
          @tokens << token.reverse
        end
        @tokens.reverse!
      end

      private

      def next_token
        return if split.nil? || content_exhausted
        token = ""
        until current_char == split[:character]
          token += current_char
          @cursor += 1
        end
        @split_index += 1
        @cursor += 1
        token
      end

      def content_exhausted
        @cursor > @content.length
      end

      def current_char
        @content[@cursor..(@cursor)]
      end

      def split
        SPLITS[@split_index]
      end
    end
  end
end