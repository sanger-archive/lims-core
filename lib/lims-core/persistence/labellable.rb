require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/labellable'

# needs to require all label subclasses
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  module Persistence
    class Labellable < Persistor
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

      class Label < Persistor
        Model = Laboratory::Labellable::Label
      end
    end
  end
end
