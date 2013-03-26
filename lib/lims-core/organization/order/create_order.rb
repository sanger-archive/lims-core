# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'
require 'lims-core/organization/order'

module Lims::Core
  module Organization
      # sources and targets represent the {Organization::Order} order {Organization::Order::Item items}.
      # source items get a "done" status and
      # target items get a "pending" status on creation. 
    class Order::CreateOrder
      include Actions::Action

      attribute :pipeline, String
      attribute :parameters, Hash, :default => {}
      # @attribute [Hash<String, String>] sources
      # @example
      #   { "role" => "{uuid of the underlying object}"}
      attribute :sources, Base::HashString, :default => {}
      # @attribute [Hash<String, String>] targets
      attribute :targets, Base::HashString, :default => {}
      #   { "role" => "{uuid of the underlying object}",
      #     "role1" => nil}
      attribute :study, Organization::Study, :required => true
      attribute :cost_code, String, :required => true

      def _call_in_session(session)
        order = Organization::Order.new(:creator => user,
                                        :pipeline => pipeline,
                                        :parameters => parameters,
                                        :study => study,
                                        :cost_code => cost_code) 

        sources.each { |role, uuid| order.add_source(role, uuid) }
        targets.each { |role, uuid| order.add_target(role, uuid) }

        session << order
        { :order => order, :uuid => session.uuid_for!(order) }
      end
    end
  end
  module Organization
    class Order
      Create = CreateOrder
    end
  end
end
