module Gemjars
  module Deux
    class ZipReader
      include Enumerable

      def initialize io
        @stream = Java::JavaUtilZip::ZipInputStream.new(Java::OrgJrubyUtil::IOInputStream.new(io))
      end

      def each &block
        while entry = @stream.next_entry
          yield entry
        end
      end
    end
  end
end
