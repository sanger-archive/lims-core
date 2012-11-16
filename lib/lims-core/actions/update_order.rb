# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/organization/order'

module Lims::Core
  module Actions
    class UpdateOrder
      include Action


      attribute :event, Symbol 
      def _call_in_session(session)
      end
    end
  end
  module Persistence
    class Order
      Update = Organization::Order
    end
  end
end
