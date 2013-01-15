require 'method_decorators'
require 'gemjar/logged'

module Gemjar
  class TaskExecutor
    extend MethodDecorators

    def initialize executors
      @executor = Java::java.util.concurrent.Executors.newFixedThreadPool(executors)
      @tasks = Java::java.util.concurrent.ConcurrentHashMap.new
    end

    +Logged.new
    def get_or_submit_task name, &block
      task = java.util.concurrent.FutureTask.new proc(&block)
      @tasks.synchronized do
        unless @tasks.get(name)
          @tasks.put name, task
          @executor.execute(@tasks.get(name))
        end
        @tasks.get(name)
      end
    end

    +Logged.new
    def destroy!
      @executor.shutdown_now
    end
  end
end