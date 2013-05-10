require 'clamp'
require 'gemjars/deux/file_store'
require 'gemjars/deux/aws_store'
require 'gemjars/deux/commands/dsl'

module Gemjars
  module Deux
    module Commands
      class Mirror < ::Clamp::Command
        include Commands::Dsl

        option ["-w", "--workers"], "WORKERS", "worker count", :attribute_name => :workers_count, :default => 5 do |s|
          Integer(s)
        end

        option ["--out"], "OUTPUT_DIRECTORY", "output directory", :attribute_name => :output_directory

        option ["--s3"], "S3_CONFIG_FILE", "s3 config file", :attribute_name => :s3_config_file

        option ["--log"], "LOG_PATH", "log file path", :default => File.new(File.expand_path("log"), "w+") do |s|
          File.new(s, "w+")
        end

        parameter "FILTERS ...", "filter gems to mirror", :required => false, :attribute_name => :filters

        def predicate
          @predicate ||= filters.empty? ? proc { true } : YankPredicate.new(filters).to_proc
        end

        def http
          @http ||= Http.default
        end

        def specs
          @specs ||= (Specifications.rubygems + Specifications.prerelease_rubygems)
        end

        def store
          if output_directory
            @store ||= FileStore.new(output_directory)
          elsif s3_config_file
            @store ||= AWSStore.from_file(s3_config_file)
          else
            raise "Either --out or --s3 must be specified."
          end
        end

        def repo
          @repo ||= MavenRepository.new(store)
        end

        def index
          @index ||= Index.new(store)
        end

        def execute
          require 'thread'
          require 'celluloid/autostart'
          logger = ::Gemjars::Deux::Logger.new
          logger.info { "Mirroring..." }
          Celluloid.logger = logger

          task_queue = PriorityQueue.new(specs)

          specs.each {|s| task_queue << s if predicate.call(s) }

          pool = (1..workers_count).to_a.map do |i|
            Gemjars::Deux::Worker.spawn("Worker #{i}", task_queue, index, http, repo, specs)
          end

          workers = Workers.new(task_queue, pool)

          Signal.trap("INT") do
            begin
              workers.halt!
            ensure
              index.flush
            end
            exit
          end

          workers.run!
        end
      end
    end
  end
end

