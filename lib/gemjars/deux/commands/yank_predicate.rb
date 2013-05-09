module Gemjars
  module Deux
    module Commands
      class YankPredicate
        def initialize parts
          @parts = parts
        end

        def to_proc
          _or(exact_match_predicate, platform_predicate)
        end

        private

        def _or *procs
          proc {|spec| procs.reduce(false) {|m, p| m || p.call(spec) }}
        end

        def exact_match_predicate
          proc {|spec| @parts.each_slice(2).to_a.include?([spec.name, spec.version]) }
        end

        def platform_predicate
          platforms = @parts.
            select {|p| p =~ /^platform:/}.
            map {|p| p.sub("platform:", "")}

          proc {|s| platforms.include?(s.platform) }
        end
      end
    end
  end
end
