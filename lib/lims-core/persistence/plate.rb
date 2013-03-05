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

      # Save all children of the given container (gel, plate)
      # @param  id object identifier
      # @param [i.e. Laboratory::Gel] container
      # @return [Boolean]
      def save_children(id, container)
        # we use values here, so position is a number
        container.values.each_with_index do |element, position|
          @session.save(element, id, position)
        end
      end

      # Load all children of the given container (gel, plate)
      # Loaded object are automatically added to the session.
      # @param id object identifier
      # @param [i.e. Laboratory::Gel] container
      # @return [i.e. Laboratory::Gel, nil] 
      #
      def load_children(id, container)
        element.load_aliquots(id) do |position, aliquot|
          container[position] << aliquot
        end
      end

      # calls the correct element method
      def element
        well
      end

      def well
        @session.send("Plate::Well")
      end

      # Base for all Well persistor.
      # Real implementation classes (e.g. Sequel::Well) should
      # include the suitable persistor.
      class Well < Persistor
        Model = Laboratory::Plate::Well

        def save(element, container_id, position)
          #todo bulk save if needed
          element.each do |aliquot|
            save_as_aggregation(container_id, aliquot, position)
          end
        end

      end
    end
  end
end
