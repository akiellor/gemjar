require 'java'
require 'tmpdir'

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