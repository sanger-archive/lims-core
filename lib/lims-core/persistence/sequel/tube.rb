# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/tube'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      # Not a tube but a tube persistor.
      class Tube < Persistence::Tube
        include Sequel::Persistor

        class TubeAliquot < Persistence::Tube::TubeAliquot
          include Sequel::Persistor

          # Do a bulk load of aliquot and pass each to a block
          # @param tube_id the id of the tube to load.
          # @yield_param [Integer] position
          # @yield_param [Aliquot] aliquot
          def load_aliquots(tube_id)
            dataset.join(Aliquot::dataset(@session), :id => :aliquot_id).filter(:tube_id => tube_id).each do |att|
              att.delete(:id)
              aliquot  = @session.aliquot.get_or_create_single_model(att[:aliquot_id], att)
              yield(aliquot)
            end
          end

          def save_raw_association(tube_id, aliquot_id)
              dataset.insert(:tube_id => tube_id, :aliquot_id  => aliquot_id)
          end
        end

        # Delete all children of the given tube
        # But don't destroy the 'external' elements (example aliquots)
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::Tube] tube
        def delete_children(id, tube)
          TubeAliquot::dataset(@session).filter(:tube_id => id).delete
        end

      end
    end
  end
end
