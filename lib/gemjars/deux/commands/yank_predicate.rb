module Gemjars
  module Deux
    module Commands
      class YankPredicate
        def initialize parts
          @parts = parts
        end

        def to_proc
          proc {|definition| @parts.each_slice(2).to_a.include?([definition[:spec][:name], definition[:spec][:version]]) }
        end
      end
    end
  end
end
