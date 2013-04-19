module Gemjars
  module Deux
    class Streams
      def self.read io
        out = StringIO.new
        while chunk = io.read(1024)
          out << chunk
        end
        out.string
      end
    end
  end
end
