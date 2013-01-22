# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/tube_rack'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      # Not a tube_rack but a tube_rack persistor.
      class TubeRack < Persistence::TubeRack
        include Sequel::Persistor

      # Not a well but a well {Persistor}.
        class Slot < Persistence::TubeRack::Slot
          include Sequel::Persistor
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
            dataset.join(Tube::dataset(@session), :id => :tube_id).filter(:tube_rack_id => tube_rack_id).each do |att|
              position = att.delete(:position)
              att.delete(:id)
              tube  = @session.tube.get_or_create_single_model(att[:tube_id], att)
              yield(position, tube)
            end
          end
        end #class Well

        def self.table_name
          :tube_racks
        end


      end
    end
  end
end
