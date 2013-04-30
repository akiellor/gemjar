require 'gemjars/deux/streams'

module Gemjars
  module Deux
    class Http
      def self.default
        new
      end

      def initialize
        connection_manager = Java::OrgApacheHttpImplConn::PoolingClientConnectionManager.new
        @client = Java::org.apache.http.impl.client.DefaultHttpClient.new(connection_manager)
      end

      def get uri
        request = Java::org.apache.http.client.methods.HttpGet.new uri

        raise "No block given" unless block_given?

        response = @client.execute(request)
        io = response.entity.content
        out = Java::JavaIo::ByteArrayOutputStream.new
        Streams.copy_channel Streams.to_channel(io), Streams.to_channel(out)
        yield Streams.to_channel(Java::JavaIo::ByteArrayInputStream.new(out.to_byte_array))
      end
    end
  end
end

