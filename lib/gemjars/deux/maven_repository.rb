require 'digest/md5'
require 'digest/sha1'

module Gemjars
  module Deux
    class MavenRepository
      class MultiChannel
        include Java::JavaNioChannels::WritableByteChannel
        
        def initialize channels
          @channels = channels
        end

        def write buffer
          @channels.each do |c|
            c.write buffer
            buffer.rewind
          end
        end

        def close
          @channels.each do |c|
            c.close
          end
        end

        def open?
          @channels.all?(&:open?)
        end
      end

      class DigestChannel
        include Java::JavaNioChannels::WritableByteChannel

        def self.md5 channel
          new channel, "MD5"
        end

        def self.sha1 channel
          new channel, "SHA1"
        end

        def initialize channel, algorithm
          @channel = channel
          @digest = Java::JavaSecurity::MessageDigest.get_instance(algorithm)
        end

        def write buffer
          @digest.update(buffer)
        end

        def close
          digest = String.from_java_bytes(@digest.digest).unpack('H*').first.to_java_bytes
          buffer = Java::JavaNio::ByteBuffer.allocate(digest.length)
          buffer.put(digest)
          buffer.flip
          @channel.write buffer
          @channel.close
        end

        def open?
          @channel.open?
        end
      end

      def initialize store
        @store = store
      end

      def pipe_to name, version
        jar_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.jar", :content_type => "application/java-archive")
        jar_md5_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.jar.md5", :content_type => "text/plain")
        jar_sha1_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.jar.sha1", :content_type => "text/plain")
        pom_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.pom", :content_type => "application/xml")
        pom_md5_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.pom.md5", :content_type => "text/plain")
        pom_sha1_w = @store.put("org/rubygems/#{name}/#{version}/#{name}-#{version}.pom.sha1", :content_type => "text/plain")

        jar = MultiChannel.new([jar_w, DigestChannel.md5(jar_md5_w), DigestChannel.sha1(jar_sha1_w)])
        pom = MultiChannel.new([pom_w, DigestChannel.md5(pom_md5_w), DigestChannel.sha1(pom_sha1_w)])

        yield jar, pom
      ensure
        jar.close if jar
        pom.close if pom
      end
    end
  end
end

