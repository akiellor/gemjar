require 'digest/md5'
require 'digest/sha1'

module Gemjars
  module Deux
    class MavenRepository
      class MultiStream
        def initialize ios
          @ios = ios
          @closed = false
        end

        def << chunk
          @ios.each do |io|
            io << chunk
          end
        end

        def close
          @ios.each do |io|
            io.close
          end
          @closed = true
        end

        def closed?
          @closed
        end
      end

      class MD5Stream
        def initialize io
          @io = io
          @digest = Digest::MD5.new
        end

        def << chunk
          @digest << chunk
        end

        def close
          @io << @digest.hexdigest
          @io.close
        end
      end

      class SHA1Stream
        def initialize io
          @io = io
          @digest = Digest::SHA1.new
        end

        def << chunk
          @digest << chunk
        end

        def close
          @io << @digest.hexdigest
          @io.close
        end
      end

      def initialize store
        @store = store
      end

      def pipe_to name, version
        jar_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.jar")
        md5_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.jar.md5")
        sha1_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.jar.sha1")

        MultiStream.new([jar_w, MD5Stream.new(md5_w), SHA1Stream.new(sha1_w)])
      end
    end
  end
end

