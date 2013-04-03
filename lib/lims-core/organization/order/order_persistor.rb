# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/persistor'
require 'lims-core/organization/order'

module Lims::Core
  module Organization
    # Base for all Order persistor.
    class Order
      class OrderPersistor < Persistence::Persistor
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

        class Item < Persistence::Persistor
          Model = Organization::Order::Item

          def filter_attributes_on_save(attributes, order_id=nil, role=nil)
            attributes = attributes.mash do |k,v|
              case k
              when :batch then [:batch_id, @session.id_for!(v)]
              else [k,v]
              end
            end
            attributes[:role] = role if role
            attributes[:order_id] = order_id if order_id
            uuid = attributes[:uuid]
            attributes[:uuid] = @session.pack_uuid(uuid) if uuid
            attributes
          end

          def filter_attributes_on_load(attributes)
            attributes = attributes.mash do |k,v|
              case k
              when :batch_id then [:batch, @session.batch[v]]
              else [k,v]
              end
            end
            uuid = attributes[:uuid]
            attributes[:uuid] = @session.unpack_uuid(uuid) if uuid
            attributes
          end
        end
      end
    end
  end
end
