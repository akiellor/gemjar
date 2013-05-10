module Gemjars
  module Deux
    class Logger
      [:debug, :error, :info, :warn].each do |level|
        define_method(level) do |*args, &block|
        msg = args.first
        if send("#{level.to_s}?".to_sym)
          msg = msg.nil? ? block.call : msg

          java_logger.send(level, msg.to_s)
        end
        end

        define_method("#{level.to_s}?".to_sym) do
          java_logger.send("#{level}_enabled?".to_sym)
        end
      end

      alias :fatal :error
      alias :fatal? :error? 

      private

      def java_logger
        Java::OrgSlf4j::LoggerFactory.get_logger("Object")
      end
    end
  end
end
