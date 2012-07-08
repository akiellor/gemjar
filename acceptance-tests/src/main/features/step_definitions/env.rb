require 'java'
require 'tmpdir'
require 'rspec/expectations'
require 'net/http'

module Acceptance
  class Configuration
    def self.server
      "http://localhost:8080"
    end

    def self.work_directory
      @work ||= Dir.mktmpdir
    end
  end
end

AfterConfiguration do
  IO.popen("java -jar #{Java::JavaLang::System.get_property("target.application")}")

  Timeout::timeout(360) do
    up = false
    until up
      begin
        res = Net::HTTP.get_response(URI.parse("#{Acceptance::Configuration.server}/ping"))
        up = res.code == "200"
      rescue Errno::ECONNREFUSED => e
      end
      sleep 10
    end
  end
end