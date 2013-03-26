require 'lims-core/laboratory/container'

module Lims::Core
  module Laboratory
    module Container::ContainerPersistor

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

      # The specific container should implement this method
      # and call the correct element method
      def element
        raise NotImplementedError
      end
    end
  end
end
