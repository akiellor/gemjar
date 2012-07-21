require 'java'
require 'tmpdir'
require 'rspec/expectations'
require 'net/http'
require 'childprocess'

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

process = ChildProcess.build("java", "-jar", Java::JavaLang::System.get_property("target.application"))
process.io.inherit!
process.start

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

at_exit do
  process.stop
end
