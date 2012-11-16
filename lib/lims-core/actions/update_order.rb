# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/organization/order'

module Lims::Core
  module Actions
    class UpdateOrder
      include Action

      #@ attribute :order
      #  The order to update.
      attribute :order, Organization::Order
      # @attribute :items
      #   a Hash of Items to *add* or *update*
      #   key are the role name
      #   value are either a uuid (String) or an event (Symbol) to send to the current item.
      attribute :items, Hash 
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
