require 'clamp'
require 'gemjars/deux/file_store'

module Gemjars
  module Deux
    module Commands
      class Mirror < ::Clamp::Command
        include Commands::Dsl

        option ["-w", "--workers"], "WORKERS", "worker count", :default => 5 do |s|
          Integer(s)
        end

        option ["--out"], "OUTPUT_DIRECTORY", "output directory", :attribute_name => :output_directory, :required => true

        option ["--log"], "LOG_PATH", "log file path", :default => File.new(File.expand_path("log"), "w+") do |s|
          File.new(s, "w+")
        end

        def http
          @http ||= Http.default
        end

        def specs
          @specs ||= Specifications.rubygems + Specifications.prerelease_rubygems
        end

        def store
          @store ||= FileStore.new(output_directory)
        end

        def repo
          @repo ||= MavenRepository.new(store)
        end

        def index
          @index = Index.spawn(store)
        end

        def execute
          require 'thread'
          require 'celluloid/autostart'

          Celluloid.logger = Logger.new(log)

          queue = Queue.new

          specs.each { |s| queue << s }

          pool = (1..workers).to_a.map do |i|
            Gemjars::Deux::Worker.spawn("Worker #{i}", queue, index, http, repo, specs)
          end

          Signal.trap("INT") do
            puts "Stopping..."
            until queue.empty?
              queue.pop
            end
            puts "Queue Drained..."

            Timeout::timeout(3 * pool.size) do
              until pool.all?(&:done?)
                sleep 1
              end
            end

            exit
          end

          pool.each {|w| w.async.run }

          pool.each {|w| w.thread.join }
        end
      end
    end
  end
end

