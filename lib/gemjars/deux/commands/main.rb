require 'clamp'
require 'gemjars/deux/commands/mirror'
require 'gemjars/deux/commands/yank'

module Gemjars
  module Deux
    module Commands
      class Main < ::Clamp::Command
        subcommand 'mirror', "Creates a gemjars mirror", Mirror
        subcommand 'yank', "Removes a gemjar from the mirror", Yank
      end
    end
  end
end

