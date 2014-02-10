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

      # Returns a list of ResourceState corresponding to all the
      # resources directly modified by this session.
      # Resources depending on a modified resource
      # which haven't been modified themself won't be return.
      # For this see @collect_related_states
      # For example if an aliquot of a plate has been modified,
      # only this aliquot will be returned. The plate won't be returned
      # even though it has been modified indirectly
      # @return [StateList]
      def collect_direct_states()
        raise NotImplementedError, "collect_direct_states method not implemented for #{self.class}"
      end
      # Returns a list of ResourceState corresponding to all
      # resources directly or indirectly modified by this session.
      # Example, if an aliquot of a plate has been modified by this session
      # The plate, and the aliquot will be returned.
      def collect_related_states()
        raise NotImplementedError, "collect_all_states method not implemented for #{self.class}"
      end
      end
    end
  end
end

