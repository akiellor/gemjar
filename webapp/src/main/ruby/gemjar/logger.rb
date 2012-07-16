module Gemjar
  class Logger
    def self.for name
      new name
    end

    def initialize name
      @logger = Java::OrgSlf4j::LoggerFactory.get_logger name
    end

    def method_missing name, *args, &block
      @logger.send name, *args
    end
  end
end