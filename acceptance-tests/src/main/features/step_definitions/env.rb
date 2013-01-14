require 'java'
require 'tmpdir'
require 'rspec/expectations'
require 'net/http'
require 'childprocess'

module Acceptance
  class Configuration
    def self.server
      @server ||= Java::Gemjar::WebServer.new.stop_at_shutdown.local_connector
    end

    def self.work_directory
      @work ||= Dir.mktmpdir
    end
  end
end

Acceptance::Configuration.server.start

at_exit do
  Acceptance::Configuration.server.stop
end

Timeout::timeout(360) do
  up = false
  until up
    begin
      response = Acceptance::Configuration.server.client.get("/ping")
      up = response.status == 200
    rescue Errno::ECONNREFUSED => e
    end
    sleep 10
  end
end
