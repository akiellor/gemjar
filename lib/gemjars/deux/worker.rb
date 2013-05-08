require 'celluloid'

module Gemjars
  module Deux
    class Worker
      include Celluloid
      include Celluloid::Logger

      attr_reader :queue, :index, :http, :repo, :specs

      def initialize name, queue, index, http, repo, specs
        @name = name
        @queue = queue
        @index = index
        @http = http
        @repo = repo
        @specs = specs
        @done = false
      end

      def run
        until queue.empty?
          spec = queue.pop

          next unless spec && !index.handled?(spec)

          begin
            http.get(spec.gem_uri) do |gem_channel|
              transform = Transform.new(spec, gem_channel)

              transform.to_mvn(specs) do |h|
                h.success do |jar, pom|
                  jar_size = nil
                  pom_size = nil

                  repo.pipe_to(spec.name, spec.version) do |out_jar, out_pom|
                    jar_size = Streams.copy_channel jar, out_jar
                    pom_size = Streams.copy_channel pom.channel, out_pom
                  end

                  index.add spec, :size => jar_size + pom_size

                  pom.dependencies.each do |spec|
                    queue.force spec
                  end

                  info "[#@name] Success -> #{{:spec => spec}.inspect}"
                end

                h.native do |exts|
                  index.add spec, :native_extensions => exts
                  warn "[#@name] Native Extensions -> #{{:spec => spec, :exts => exts}.inspect}"
                end

                h.unsatisfied_dependencies do |deps|
                  index.add spec, :unsatisfied_dependencies => deps
                  warn "[#@name] Unsatisfied Dependency -> #{{:spec => spec, :deps => deps}.inspect}"
                end
              end
            end
          rescue => e
            error "[#@name] Exception -> #{{:spec => spec, :exception => e, :backtrace => e.backtrace}.inspect}"
          end

          $stdout.print "  #{queue.size}/#{specs.size}  #{((queue.size.to_f / specs.size.to_f) * 100).to_i}% #{" " * 100}\r"
          $stdout.flush
        end
        @done = true
      end

      def done?
        @done
      end
    end
  end
end
