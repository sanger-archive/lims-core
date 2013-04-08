require 'lims-core/laboratory/spin_column/spin_column_persistor'
require 'lims-core/persistence/sequel/persistor'

module Lims::Core
  module Laboratory
    # a spin column persistor.
    class SpinColumn
      class SpinColumnSequelPersistor < SpinColumnPersistor
        include Persistence::Sequel::Persistor
        # Delete all children of the given spin column
        # But don't destroy the 'external' elements (example aliquots)
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::SpinColumn] spin column
        def delete_children(id, spin_column)
          SpinColumnAliquot::SpinColumnSequelAliquotPersistor::dataset(@session).filter(:spin_column_id => id).delete
        end
      end

      module SpinColumnAliquot
        class SpinColumnSequelAliquotPersistor < SpinColumnAliquotPersistor
          include Persistence::Sequel::Persistor

          # Do a bulk load of aliquot and pass each to a block
          # @param spin_column_id the id of the spin column to load.
          # @yieldparam [Integer] position
          # @yieldparam [Aliquot] aliquot
          def load_aliquots(spin_column_id)
            dataset.join(@session.aliquot.dataset, :id => :aliquot_id).filter(:spin_column_id => spin_column_id).each do |att|
              att.delete(:id)
              aliquot  = @session.aliquot.get_or_create_single_model(att[:aliquot_id], att)
              yield(aliquot)
            end
          end

          def save_raw_association(spin_column_id, aliquot_id)
            dataset.insert(:spin_column_id => spin_column_id, :aliquot_id  => aliquot_id)
          end
        end
      end
    end
  end
end
