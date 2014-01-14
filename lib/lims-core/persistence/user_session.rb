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

      def session
        raise NotImplementedError, "session method not implemented for #{self.class}"
      end

      def method_missing(*args, &block)
        session.public_send(*args, &block)
      end
    end
  end
end


