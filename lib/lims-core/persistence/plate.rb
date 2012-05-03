# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/plate'

module Lims::Core
  module Persistence

    # Base for all Plate persistor.
    # Real implementation classes (e.g. Sequel::Plate) should
    # include the suitable persistor.
    class Plate < Persistor
      Model = Laboratory::Plate

      # Save all children of the given plate
      # @param  id object identifier
      # @param [Laboratory::Plate] plate
      # @return [Boolean]
      def save_children(id, plate)
        # we use values here, so position is a number
        plate.values.each_with_index do |well, position|
          @session.save(well, id, position)
        end
      end

      # Load all children of the given plate
      # Loaded object are automatically added to the session.
      # @param  id object identifier
      # @param [Laboratory::Plate] plate
      # @return [Laboratory::Plate, nil] 
      #
      def load_children(id, plate)
        well.load_aliquots(id) do |position, aliquot|
          plate[position] << aliquot
        end
      end

      def well
        @session.send("Plate::Well")
      end

      # Base for all Well persistor.
      # Real implementation classes (e.g. Sequel::Well) should
      # include the suitable persistor.
      class Well < Persistor
        Model = Laboratory::Plate::Well

        def save(well, plate_id, position)
          #todo bulk save if needed
          well.each do |aliquot|
            save_as_aggregation(plate_id, aliquot, position)
          end
        end
      end
    end
  end
end
