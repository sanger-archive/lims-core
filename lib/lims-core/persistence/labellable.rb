require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/labellable'
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  module Persistence
    class Labellable < Persistor
      Model = Laboratory::Labellable

      def content
        @session.send("Labellable::Label")
      end

      # Saves all children of a given Labellable
      def save_children(id, labellable)
        labellable.each do |position, label|
          @session.save(label, id, position)
        end
      end

      # Loads all children of a given Labellable
      def load_children(id, labellable)
        content.loads(id) do |position, label|
          labellable[position] = label
        end
      end

      class Label < Persistor
        #TODO ke4 replace it with proper model instance
        Model = Laboratory::SangerBarcode

      end
    end
  end
end
