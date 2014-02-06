require 'lims-core/persistence/sequel/session'
require 'lims-core/persistence/sequel/session_finder/persistor'

module Lims::Core
  module Persistence
    module Sequel
      module SessionFinder
        # Special session allowing to find all the sessions having
        # an impact on a given set of objects.
        # The session keeps track of all user_session found
        # Therefore, it should only be used once per 'request'.,w
        class Session < Sequel::Session
          attr_reader :session_ids
          def initialize(store)
            @store = store
            @session_ids = Set.new
            super(store)
          end
        end
      end
    end
  end
end
