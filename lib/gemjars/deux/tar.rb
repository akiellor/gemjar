module Gemjars
  module Deux
    class Tar
      include Enumerable
      
      def initialize io
        @stream = Java::OrgKamranzafarJtar::TarInputStream.new(Java::OrgJrubyUtil::IOInputStream.new(io))
      end

      def each
        while entry = @stream.next_entry
          yield entry
        end
      end
    end
  end
end
