module Gemjar
  module Logger
    extend self

    def self.included base
      base.extend self
    end

    def log
      name = self.respond_to?(:name) ? self.name : self.class.name
      @log ||= Java::OrgSlf4j::LoggerFactory.get_logger name
    end
  end
end