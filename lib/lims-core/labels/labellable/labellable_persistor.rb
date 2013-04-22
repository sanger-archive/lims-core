require 'lims-core/persistence/persistor'
require 'lims-core/labels/labellable'

# needs to require all label subclasses
require 'lims-core/labels/sanger_barcode'

module Lims::Core
  module Labels
    class Labellable
      class LabellablePersistor < Persistence::Persistor
        Model = Labels::Labellable

        def label
          @session.labellable_label
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
      end
      module Label 
        SESSION_NAME=:labellable_label
        class LabelPersistor < Persistence::Persistor
          Model = Labels::Labellable::Label
        end
      end
    end
  end
end
