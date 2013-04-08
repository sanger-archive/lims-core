# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/laboratory/flowcell/flowcell_persistor'
require 'lims-core/persistence/sequel/persistor'

module Lims::Core
  module Laboratory
    # Not a flowcell but a flowcell persistor.
    class Flowcell
      # Not a lane but a lane {Persistor}.
      class Lane 
        class LaneSequelPersistor < LanePersistor
          include Persistence::Sequel::Persistor
          def self.table_name
            :lanes
          end

          def save_raw_association(flowcell_id, aliquot_id, position)
            dataset.insert(:flowcell_id => flowcell_id,
              :position => position,
              :aliquot_id  => aliquot_id)
          end

          # Do a bulk load of aliquot and pass each of a block
          # @param flowcell_id the id of the flowcell to load.
          # @yieldparam [Integer] position
          # @yieldparam [Aliquot] aliquot
          def load_aliquots(flowcell_id)
            dataset.join(@session.aliquot.dataset, :id => :aliquot_id).filter(:flowcell_id => flowcell_id).each do |att|
              position = att.delete(:position)
              att.delete(:id)
              aliquot  = @session.aliquot.get_or_create_single_model(att[:aliquot_id],  att )
              yield(position, aliquot)
            end
          end
        end #class Lane
      end
      class FlowcellSequelPersistor < FlowcellPersistor
        include Persistence::Sequel::Persistor


        def self.table_name
          :flowcells
        end

        # Save all children of the given flowcell
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::Flowcell] flowcell
        # @return [Boolean]
        def save_children(id, flowcell)
          flowcell.each_with_index do |lane, position|
            @session.save(lane, id, position)
          end
        end

        # Delete all children of the given flowcell
        # But don't destroy the 'external' elements (example aliquots)
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::Flowcell] flowcell
        def delete_children(id, flowcell)
          @session.flowcell_lane.dataset.filter(:flowcell_id => id).delete
        end

        def lane
          @session.flowcell_lane
        end

        # Load all children of the given flowcell
        # Loaded object are automatically added to the session.
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::Flowcell] flowcell
        # @return [Laboratory::Flowcell, nil] 
        #
        def load_children(id, flowcell)
          lane.load_aliquots(id) do |position, aliquot|
            flowcell[position] << aliquot
          end
        end
      end
    end
  end
end
