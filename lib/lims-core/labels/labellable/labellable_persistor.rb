require 'lims-core/persistence/persistor'
require 'lims-core/labels/labellable'

# needs to require all label subclasses
require 'lims-core/laboratory/sanger_barcode'

module Lims::Core
  module Labels
    class Labellable::LabellablePersistor < Persistence::Persistor
      Model = Laboratory::Labellable

      def label
        @session.send("Labellable::Label")
      end

      # Saves all children of a given Labellable
      def save_children(id, labellable)
        labellable.each do |position, label_object|
          label.save(label_object, id, position)
        end
      end

      # Loads all children of a given Labellable
      def load_children(id, labellable)
        label.load(id) do |position, label|
          labellable[position]=label
        end
      end


      class Label < Persistence::Persistor
        Model = Laboratory::Labellable::Label
      end
    end
  end
end
