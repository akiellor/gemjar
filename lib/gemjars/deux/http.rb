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
        yield Streams.to_channel(io)
      ensure
        io.close if io
      end
    end
  end
end

