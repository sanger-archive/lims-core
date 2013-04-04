require 'lims-core/laboratory/aliquot/aliquot_sequel_persistor'

module Lims::Core
  module Laboratory
    module Container::ContainerSequelPersistor

      # The specific container should implement this method
      # and return the proper container_id with symbol type
      # i. e. :gel_id
      def container_id_sym
        raise NotImplementedError
      end

      # The specific container should implement this method
      # and return the proper dataset of the element of the container
      # i.e. in the case of Gel: Window::dataset(@session)
      def element_dataset
        raise NotImplementedError
      end

      # Delete all children of the given container
      # But don't destroy the 'external' elements (example aliquots)
      # @param [Fixnum] id the id in the database
      # @param [i.e. Laboratory::Gel] container
      def delete_children(id, gel)
        element_dataset.filter(container_id_sym => id).delete
      end

      # Load all children of the given container
      # Loaded object are automatically added to the session.
      # @param [Fixnum] id the id in the database
      # @param [i.e. Laboratory::Gel] container
      # @return [i.e. Laboratory::Gel, nil] 
      def load_children(id, container)
        element.load_aliquots(id) do |position, aliquot|
          container[position] << aliquot
        end
      end

    end
  end
end
