require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/gel'

module Lims::Core
  module Persistence

    # Base for all Gel persistor.
    # Real implementation classes (e.g. Sequel::Gel) should
    # include the suitable persistor.
    class Gel < Persistor
      Model = Laboratory::Gel

      # Save all children of the given gel
      # @param  id object identifier
      # @param [Laboratory::Gel] gel
      # @return [Boolean]
      def save_children(id, gel)
        # we use values here, so position is a number
        gel.values.each_with_index do |window, position|
          @session.save(window, id, position)
        end
      end

      # Load all children of the given gel
      # Loaded object are automatically added to the session.
      # @param id object identifier
      # @param [Laboratory::Gel] gel
      # @return [Laboratory::Gel, nil] 
      #
      def load_children(id, gel)
        window.load_aliquots(id) do |position, aliquot|
          gel[position] << aliquot
        end
      end

      def window
        @session.send("Gel::Window")
      end

      # Base for all Window persistor.
      # Real implementation classes (e.g. Sequel::Window) should
      # include the suitable persistor.
      class Window < Persistor
        Model = Laboratory::Gel::Window

        def save(window, gel_id, position)
          #todo bulk save if needed
          window.each do |aliquot|
            save_as_aggregation(gel_id, aliquot, position)
          end
        end
      end
    end
  end
end
