# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'sequel'
require 'lims/core/persistence'

module Lims::Core
  module Persistence
    module Sequel
      # Sequel specific implementation of a {Persistence::Session Session}.
      class Session < Persistence::Session
      end
    end
  end
end
