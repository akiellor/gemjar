require 'celluloid'

module Gemjars
  module Deux
    class Worker
      include Celluloid

      attr_reader :queue, :index, :http, :repo, :specs

      def initialize queue, index, http, repo, specs
        @queue = queue
        @index = index
        @http = http
        @repo = repo
        @specs = specs
      end

      def run
        until queue.empty?
          spec = queue.pop

          next if index.handled?(spec)

          begin
            gem_io = http.get(spec.gem_uri)

            transform = Transform.new(spec.name, spec.version, gem_io)

            transform.to_mvn(specs) do |h|
              h.success do |jar, pom|
                begin
                  out_jar, out_pom = repo.pipe_to(spec.name, spec.version)

                  while jar_chunk = jar.read(1024) || pom_chunk = pom.read(1024)
                    out_jar << jar_chunk if jar_chunk
                    out_pom << pom_chunk if pom_chunk
                  end
                ensure
                  out_jar.close
                  out_pom.close
                end

                index.add spec

                $stdout.puts "Success -> #{{:spec => spec}.inspect}"
              end

              h.native do |exts|
                $stderr.puts "Native Extensions -> #{{:spec => spec, :exts => exts}.inspect}"
              end
            end
          rescue => e
            $stderr.puts "Exception -> #{{:spec => spec, :exception => e, :backtrace => e.backtrace}.inspect}"
          end
        end
      end
    end
  end
end
