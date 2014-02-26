# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'common'

require 'lims-core/resource'
require 'lims-core/persistence/resource_state'

module Lims::Core
  module Persistence
    # This should be a read-only class used
    # to retrieve information related to specific
    # session. Each time a user creates a writable session
    # The `session` table is updated (via trigger).
    # This class is to read this table.
    # It also allows the user to load an object
    # as it was at a specific time (through the underlying session)
    # In the contrary of other resource, the session id
    # is part of a UserSession attribute. That is required
    # by the underlying session.
    class UserSession
      include Resource
      attribute :id, Object
      attribute :user, String
      attribute :backend_application_id, String
      attribute :parameters, Object
      attribute :success, Boolean
      attribute :start_time, Time
      attribute :end_time, Time
      attribute :parent_session, Session, :writer => :private, :initializable => true

      def with_session
        persistor.revision_session_for(self).with_session { |s| yield(s) }
      end

      def persistor
        parent_session.user_session
      end

      def attributes
        {
          :id => @id, :user => @user, :backend_application_id => @backend_application_id,
          :parameters => @parameters, :success => @success, :start_time => @start_time,
          :end_time => @end_time
        }
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
        persistor.collect_direct_states(self)
      end

      # Returns a list of ResourceState corresponding to all
      # resources directly or indirectly modified by this session.
      # Example, if an aliquot of a plate has been modified by this session
      # The plate, and the aliquot will be returned.
      def collect_related_states()
        persistor.collect_related_states(self)
      end

      # Load directly modified objects
      def direct_revisions
        revisions_for(collect_direct_states)
      end

      # Retrieve the Revisions corresponding to a set of Resource
      # or ResourceState . If Resource are used instead of ResourceState,
      # external session MUST be provided.
      def revisions_for(objects, external_session=nil)
        with_session do |session|
          session.load_from_external_states(objects, external_session) do |_, resource_states|
            resource_states.map(&:revision)
          end
        end
      end

      def related_revisions
        revisions_for(collect_related_states)
      end

      def method_missing(*args, &block)
        session.public_send(*args, &block)
      end
    end
  end
end


