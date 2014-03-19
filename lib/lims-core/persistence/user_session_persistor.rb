require 'common'

require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/session'
require 'lims-core/persistence/user_session'

require 'lims-core/persistence/revision_persistor'

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

        def revision_session_for(user_session)
          @session.class::parent_scope::Revision::Session.new(@session.store, user_session.id)
        end

        def filter_attributes_on_load(attributes, *params)
          attributes.tap do |att|
            att[:parent_session] = @session
          end
        end

        def with_session(session_id)
          model.new(:id => session_id, :parent_session => @session).with_session
        end

        # Returns a list of ResourceState corresponding to all the
        # resources directly modified by this session.
        # Resources depending on a modified resource
        # which haven't been modified themself won't be return.
        # For this see @collect_related_states
        # For example if an aliquot of a plate has been modified,
        # only this aliquot will be returned. The plate won't be returned
        # even though it has been modified indirectly
        # @param [UserSession] user_session
        # @return [StateList]
        def collect_direct_states(user_session)
          raise NotImplementedError, "collect_direct_states method not implemented for #{self.class}"
        end
        # Returns a list of ResourceState corresponding to all
        # resources directly or indirectly modified by this session.
        # Example, if an aliquot of a plate has been modified by this session
        # The plate, and the aliquot will be returned.
        # @param [UserSession] user_session
        # @return [StateList]
        def collect_related_states(user_session)
          raise NotImplementedError, "collect_all_states method not implemented for #{self.class}"
        end
      end
    end
  end
end

