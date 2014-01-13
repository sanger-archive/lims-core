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
    # It also allow the user to load an object
    # as it was at a specific time.
    class UserSession
      include Resource
      attribute :user, String
      attribute :backend_application_id, String
      attribute :parameters, Object
      attribute :succes, Boolean
      attribute :start_time, Time
      attribute :end_time, Time
    end
  end
end


