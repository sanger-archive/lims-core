# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims-core/persistence/persistor'
require 'lims-core/laboratory/tube'

module Lims::Core
  module Laboratory

    # Base for all Tube persistor.
    # Real implementation classes (e.g. Sequel::Tube) should
    # include the suitable persistor.
    class Tube
      class TubePersistor < Persistence::Persistor
        Model = Laboratory::Tube

        # Save all children of the given tube
        # @param  id object identifier
        # @param [Laboratory::Tube] tube
        # @return [Boolean]
        def save_children(id, tube)
          # we use values here, so position is a number
          tube.each do |aliquot|
            tube_aliquot.save_as_aggregation(id, aliquot)
          end
        end

        def  tube_aliquot
          @session.send("Tube::TubeAliquot")
        end

        class Tube
          class TubeAliquotPersistor < Persistence::Persistor
          end
        end

        # Load all children of the given tube
        # Loaded object are automatically added to the session.
        # @param  id object identifier
        # @param [Laboratory::Tube] tube
        # @return [Laboratory::Tube, nil] 
        #
        def load_children(id, tube)
          tube_aliquot.load_aliquots(id) do |aliquot|
            tube << aliquot
          end
        end
      end
    end
  end
end
