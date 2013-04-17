require 'gemjars/deux/zip'

module Gemjars
  module Deux
    class Transform
      def self.apply gem_io, jar_io
      ensure
        jar_io.close
        gem_io.close
      end
    end
  end
end

