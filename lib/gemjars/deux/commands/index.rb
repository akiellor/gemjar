require 'clamp'
require 'gemjars/deux/commands/dsl'

module Gemjars
  module Deux
    module Commands
      class Index < Clamp::Command
        include Commands::Dsl

        option ["--out"], "OUTPUT_DIRECTORY", "output directory", :attribute_name => :output_directory

        option ["--s3"], "S3_CONFIG_FILE", "s3 config file", :attribute_name => :s3_config_file

        def store
          if output_directory
            @store ||= FileStore.new(output_directory)
          elsif s3_config_file
            @store ||= AWSStore.from_file(s3_config_file)
          else
            raise "Either --out or --s3 must be specified."
          end
        end

        def index
          @index ||= Deux::Index::In.new(store)
        end

        def execute
          require 'thread'
          queue = Queue.new

          printer = Thread.new do
            loop do
              puts queue.pop unless queue.empty?
              break if Thread.current['shutdown'] && queue.empty?
            end
          end

          index.each do |args|
            spec, metadata = *args
            if metadata.has_key?(:size)
              msg = "A #{spec.identifier}"
            elsif metadata.has_key?(:unsatisfied_dependencies)
              msg = "U #{spec.identifier}"
            elsif metadata.has_key?(:native_extensions)
              msg = "N #{spec.identifier}"
            end
            queue << msg
          end
          printer['shutdown'] = true
          printer.join
        end
      end
    end
  end
end

