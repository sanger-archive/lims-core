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
      attribute :items, Hash , :default => {}
      attribute :event, Symbol 
      attribute :pipeline, String
      attribute :study, Organization::Study
      attribute :creator, Organization::User
      attribute :cost_code, String
      attribute :parameters, Hash
      attribute :state, Hash
      def _call_in_session(session)
        items.each { |role, args| update_item(role, args) }
        if event.present?
          order.public_send("#{event}!")
        end
        %w[pipeline creator cost_code study parameters state].each do |key|
          value = self[key]
          order[key] = value if value
        end
        {:order => order }
      end

      def update_item(role, args)
        item = order.fetch(role) { |k|  order[k]= Organization::Order::Item.new }
        args["uuid"].andtap { |uuid| item.uuid = uuid }
        args["event"].andtap { |event| item.public_send("#{event}!") }
      end
    end
  end

  module Organization
    class Order
      Update = Actions::UpdateOrder
    end
  end
end
