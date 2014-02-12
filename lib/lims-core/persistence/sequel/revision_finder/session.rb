require 'lims-core/persistence/sequel/session'
require 'lims-core/persistence/sequel/session_finder/session'
require 'lims-core/persistence/sequel/revision_finder/persistor'

module Lims::Core
  module Persistence
    module Sequel
      module RevisionFinder
        # Special session allowing to find all the resources
        # which have been modified indirectly by a given session.
        # Therefore, it should only be used once per 'request'.,w
        class Session < Sequel::Revision::Session
        end
      end
    end
  end
end
