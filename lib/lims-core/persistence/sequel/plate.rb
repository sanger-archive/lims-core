# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/plate'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      # Not a plate but a plate persistor.
      class Plate < Persistence::Plate
        include Sequel::Persistor

      # Not a well but a well {Persistor}.
        class Well < Persistence::Plate::Well
          include Sequel::Persistor
          def self.table_name
            :wells
          end

          def save_raw_association(plate_id, aliquot_id, position)
              dataset.insert(:plate_id => plate_id,
                             :position => position,
                             :aliquot_id  => aliquot_id)
          end

          # Do a bulk load of aliquot and pass each to a block
          # @param plate_id the id of the plate to load.
          # @yield_param [Integer] position
          # @yield_param [Aliquot] aliquot
          def load_aliquots(plate_id)
            Well::dataset(@session).join(Aliquot::dataset(@session), :id => :aliquot_id).filter(:plate_id => plate_id).each do |att|
              position = att.delete(:position)
              att.delete(:id)
              aliquot  = @session.aliquot[:aliquot_id] || Aliquot::Model.new(att)
              yield(position, aliquot)
            end
          end
        end #class Well

        def self.table_name
          :plates
        end

        # Delete all children of the given plate
        # But don't destroy the 'external' elements (example aliquots)
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::Plate] plate
        def delete_children(id, plate)
          Well::dataset(@session).filter(:plate_id => id).delete
        end

        # Load all children of the given plate
        # Loaded object are automatically added to the session.
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::Plate] plate
        # @return [Laboratory::Plate, nil] 
        #
        def load_children(id, plate)
          well.load_aliquots(id) do |position, aliquot|
            plate[position] << aliquot
          end
        end
      end
    end
  end
end
