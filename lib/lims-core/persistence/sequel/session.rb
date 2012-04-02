# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'sequel'
require 'lims/core/persistence/session'
# @todo find a way to do this automatically
require 'lims/core/persistence/sequel/flowcell'
require 'lims/core/persistence/sequel/aliquot'
require 'lims/core/persistence/sequel/plate'

module Lims::Core
  module Persistence
    module Sequel
      # Sequel specific implementation of a {Persistence::Session Session}.
      class Session < Persistence::Session
      end
    end
  end
end
