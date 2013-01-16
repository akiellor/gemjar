require 'method_decorators'

module Gemjar
  class Logged < MethodDecorator
    def call(wrapped, this, *args, &blk)
      logger = Java::OrgSlf4j::LoggerFactory.get_logger this.class.name
      logger.info("{} => {}", wrapped.name, args.inspect)
      begin
        result = wrapped.call(*args, &blk)
      rescue => e
        logger.warn(e.message, e)
        raise e
      end
      logger.info("{} <= {}", wrapped.name, result.inspect)
      result
    end
  end
end