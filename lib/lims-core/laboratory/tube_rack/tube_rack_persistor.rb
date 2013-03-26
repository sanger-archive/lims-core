# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims-core/persistence/persistor'
require 'lims-core/laboratory/tube_rack'

module Lims::Core
  module Laboratory

    # Base for all TubeRack persistor.
    # Real implementation classes (e.g. Sequel::TubeRack) should
    # include the suitable persistor.
    class TubeRack::TubeRackPersistor < Persistence::Persistor
      Model = Laboratory::TubeRack

      # Save all children of the given tube_rack
      # @param  id object identifier
      # @param [Laboratory::TubeRack] tube_rack
      # @return [Boolean]
      def save_children(id, tube_rack)
        # we use values here, so position is a number
        tube_rack.values.each_with_index do |tube, position|
          next if nil
          slot.save_as_association(id, tube, position)
        end
      end

      # Load all children of the given tube_rack
      # Loaded object are automatically added to the session.
      # @param  id object identifier
      # @param [Laboratory::TubeRack] tube_rack
      # @return [Laboratory::TubeRack, nil] 
      #
      def load_children(id, tube_rack)
        slot.load_tubes(id) do |position, tube|
          tube_rack[position]= tube
        end
      end

      def slot
        @session.send("TubeRack::Slot")
      end

      class Slot < Persistence::Persistor
      end
    end
  end
end
