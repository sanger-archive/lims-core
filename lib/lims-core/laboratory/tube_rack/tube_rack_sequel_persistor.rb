# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/laboratory/tube_rack/tube_rack_persistor'
require 'lims-core/persistence/sequel/persistor'

module Lims::Core
  module Laboratory
    # Not a tube_rack but a tube_rack persistor.
    class TubeRack
      class TubeRackSequelPersistor < TubeRackPersistor
        include Persistence::Sequel::Persistor


        def self.table_name
          :tube_racks
        end

        # Delete the tube, rack association, but doesn't delete the tube.
        def delete_children(id, tube_rack)
          @session.tube_rack_slot.dataset.filter(:tube_rack_id => id).delete
        end
      end
      # Not a slot but a slot {Persistor}.
      class Slot 
        class SlotSequelPersitor < SlotPersistor
          include Persistence::Sequel::Persistor
          def self.table_name
            :tube_rack_slots
          end

          def save_raw_association(tube_rack_id, tube_id, position)
            dataset.insert(:tube_rack_id => tube_rack_id,
              :position => position,
              :tube_id  => tube_id)
          end

          # Do a bulk load of aliquot and pass each to a block
          # @param tube_rack_id the id of the tube_rack to load.
          # @yieldparam [Integer] position
          # @yieldparam [Aliquot] aliquot
          def load_tubes(tube_rack_id)
            dataset.join(@session.tube.dataset, :id => :tube_id).filter(:tube_rack_id => tube_rack_id).each do |att|
              position = att.delete(:position)
              att.delete(:id)
              tube  = @session.tube.get_or_create_single_model(att[:tube_id], att)
              yield(position, tube)
            end
          end
        end
      end #class Slot
    end
  end
end
