require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/gel'

module Lims::Core
  module Persistence

    # Base for all Gel persistor.
    # Real implementation classes (e.g. Sequel::Gel) should
    # include the suitable persistor.
    class Gel < Persistor
      Model = Laboratory::Gel

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
        window
      end

      def window
        @session.send("Gel::Window")
      end

      # Base for all Window persistor.
      # Real implementation classes (e.g. Sequel::Window) should
      # include the suitable persistor.
      class Window < Persistor
        Model = Laboratory::Gel::Window

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
