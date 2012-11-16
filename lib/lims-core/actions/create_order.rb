# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'
require 'lims-core/organization/order'

module Lims::Core
  module Actions
    class CreateOrder
      include Action

      attribute :pipeline, String
      attribute :parameters, Hash, :default => {}
      attribute :sources, Resource::HashString, :default => {}
      attribute :targets, Resource::HashString, :default => {}
      attribute :study, Organization::Study, :required => true
      attribute :cost_code, String, :required => true

      def _call_in_session(session)
        order_items = {}
        {:done => sources, :pending => targets}.each do |status, items|
          items.each do |role, uuid|
            order_items[role] = Organization::Order::Item.new({:uuid => uuid, :status => status.to_s})
          end
        end

        order = Organization::Order.new(:creator => user,
                                        :pipeline => pipeline,
                                        :parameters => parameters,
                                        :items => order_items,
                                        :study => study,
                                        :cost_code => cost_code) 
        session << order
        { :order => order, :uuid => session.uuid_for!(order) }
      end
    end
  end
  module Organization
    class Order
      Create = Actions::CreateOrder
    end
  end
end
