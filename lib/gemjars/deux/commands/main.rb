require 'clamp'
require 'gemjars/deux/commands/mirror'
require 'gemjars/deux/commands/yank'
require 'gemjars/deux/commands/index'

module Gemjars
  module Deux
    module Commands
      class Main < ::Clamp::Command
        subcommand 'mirror', "Creates a gemjars mirror", Mirror
        subcommand 'yank', "Removes a gemjar from the mirror", Yank
        subcommand 'index', "Shows the current index", Commands::Index
      end
    end
  end
end

