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

          next if index.handled?(spec)

          begin
            http.get(spec.gem_uri) do |gem_io|
              transform = Transform.new(spec.name, spec.version, gem_io)

              transform.to_mvn(specs) do |h|
                h.success do |jar, pom|
                  repo.pipe_to(spec.name, spec.version) do |out_jar, out_pom|
                    while (jar_chunk = jar.read(1024)) || (pom_chunk = pom.read(1024))
                      out_jar << jar_chunk if jar_chunk
                      out_pom << pom_chunk if pom_chunk
                    end
                  end

                  index.add spec

                  info "[#@name] Success -> #{{:spec => spec}.inspect}"
                end

                h.native do |exts|
                  warn "[#@name] Native Extensions -> #{{:spec => spec, :exts => exts}.inspect}"
                end
              end
            end
          rescue => e
            error "[#@name] Exception -> #{{:spec => spec, :exception => e, :backtrace => e.backtrace}.inspect}"
          end
        end
        @done = true
      end

      def done?
        @done
      end
    end
  end
end
