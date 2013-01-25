# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/persistor'
require 'lims/core/organization/order'

module Lims::Core
  module Persistence
    # Base for all Order persistor.
    class Order < Persistor
      Model = Organization::Order

      # Saves all children of the given order
      # @param id obect identifier
      # @param [Organization::Order] order
      # @return [Boolean]
      def save_children(id, order)
        order.each do |role, item|
          @session.save(item, id, role)
        end
      end

      # Loads all children of the given order

      # @param  id object identifier
      # @param [Organization::Order] order
      # @return [Organization::Order, nil] 
      #
      def load_children(id, order)
        item.loads(id) do |role, item|
          order[role] = item
        end
      end

      def item
        @session.send("Order::Item")
      end

      class Item < Persistor
        Model = Organization::Order::Item

        def filter_attributes_on_save(attributes, order_id=nil, role=nil)
          attributes[:role] = role if role
          attributes[:order_id] = order_id if order_id
          uuid = attributes[:uuid]
          attributes[:uuid] = @session.pack_uuid(uuid) unless uuid.nil?
          attributes
        end

        def filter_attributes_on_load(attributes)
          uuid = attributes[:uuid]
          attributes[:uuid] = @session.unpack_uuid(uuid) unless uuid.nil?
          attributes
        end
      end
    end
  end
end
