module Gemjar
  class RequestLog
    def initialize(app)
      @app = app
      @logger = Java::OrgSlf4j::LoggerFactory.get_logger self.class.name
    end

    def call(env)
      @logger.info "#{env['REQUEST_METHOD']} #{env['REQUEST_URI']}"
      @app.call(env)
    end
  end
end