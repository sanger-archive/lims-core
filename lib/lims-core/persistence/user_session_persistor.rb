require 'common'

require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/session'
require 'lims-core/persistence/user_session'

module Lims::Core
  module Persistence
    class UserSession

      (does 'lims/core/persistence/persistable').class_eval do
        def bulk_insert(*args, &block)
          raise Session::ReadonlyClassException(UserSession)
        end

        def keep_primary_key?
          true
        end

        def for_resources(resources)
          self[session_ids_for(resources)]
        end

        def session_ids_for(*args, &block)
          raise NotImplementedError
        end
      end
    end
  end
end

