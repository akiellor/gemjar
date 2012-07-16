module Gemjar
  module Logger
    def self.included base
      base.extend Gemjar::Logger
    end

    def log
      @log ||= Java::OrgSlf4j::LoggerFactory.get_logger self.name
    end
  end
end