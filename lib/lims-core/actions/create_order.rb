# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'
require 'lims-core/organization/order'

module Lims::Core
  module Actions
    class CreateOrder
      include Action

      attribute :pipeline, String
      attribute :parameters, Hash, :default => {}
      # @attribute [Hash<String, String>] sources
      # @attribute [Hash<String, String>] targets
      # @example
      # { "role" => "{uuid of the underlying object}"}
      # sources and targets represent the Order items.
      # source items get a "done" status and
      # target items get a "pending" status on creation. 
      attribute :sources, Resource::HashString, :default => {}
      attribute :targets, Resource::HashString, :default => {}
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
      Create = Actions::CreateOrder
    end
  end
end
