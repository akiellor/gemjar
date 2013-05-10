require 'clamp'
require 'gemjars/deux/commands/dsl'

module Gemjars
  module Deux
    module Commands
      class Index < Clamp::Command
        include Commands::Dsl

        option ["--out"], "OUTPUT_DIRECTORY", "output directory", :attribute_name => :output_directory

        option ["--s3"], "S3_CONFIG_FILE", "s3 config file", :attribute_name => :s3_config_file

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

        def index
          @index ||= Deux::Index.new(store)
        end

        def execute
          specs.each do |spec|
            if index.handled?(spec)
              puts "A #{spec.identifier}"
            elsif index.include?(spec)
              puts "U #{spec.identifier}"
            else
              puts "E #{spec.identifier}"
            end
          end
        end
      end
    end
  end
end

