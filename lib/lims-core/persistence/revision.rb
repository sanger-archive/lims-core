require 'lims-core/resource'
require 'lims-core/persistence'


module Lims::Core
  module Persistence
    # Class representing the revision of a Resource and corresponds
    # to one row in a 'revision' table.
    # The resource is the state of the Resource for that particular
    # session_id.
    # The other fields describes 
    class Revision
      include Resource
      attribute :id, Object
      attribute :number, Fixnum
      attribute :action, String
      attribute :session_id, Object

      attribute :resource, Object
      attribute :model, Object

    end
  end
end
