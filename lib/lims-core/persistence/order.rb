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
        order.each do |role, items|
          items.each do |item|
            @session.save(item, id, role)
          end
        end
      end

      # Loads all children of the given order

      # @param  id object identifier
      # @param [Organization::Order] order
      # @return [Organization::Order, nil] 
      #
      def load_children(id, order)
        # We don't really need to keep the order of the item
        # however as the user can update an item via is index
        # it's need to be the same between what we display
        # and how we load items.
        # For this items are loaded sorted by id
        # So they should be always presented the same way (between and load and a save)
        item.loads(id) do |role, item|
          order.add_item(role, item)
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
          attributes[:uuid] = @session.pack_uuid(uuid) if uuid
          batch_uuid = attributes[:batch_uuid]
          attributes[:batch_uuid] = @session.pack_uuid(batch_uuid) if batch_uuid
          attributes
        end

        def filter_attributes_on_load(attributes)
          uuid = attributes[:uuid]
          attributes[:uuid] = @session.unpack_uuid(uuid) if uuid
          batch_uuid = attributes[:batch_uuid]
          attributes[:batch_uuid] = @session.unpack_uuid(batch_uuid) if batch_uuid
          attributes
        end
      end
    end
  end
end
