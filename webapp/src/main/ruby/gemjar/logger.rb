require 'method_decorators'

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

  class Logged < MethodDecorator
    def call(wrapped, this, *args, &blk)
      logger = Java::OrgSlf4j::LoggerFactory.get_logger this.class.name
      logger.info("{} => {}", wrapped.name, args.inspect)
      begin
        result = wrapped.call(*args, &blk)
      rescue => e
        logger.warn(e)
        raise e
      end
      logger.info("{} <= {}", wrapped.name, result.inspect)
      result
    end
  end
end