require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/labellable'

module Lims::Core
  module Persistence
    class Labellable < Persistor
      Model = Laboratory::Labellable

      def content
        @session.send("Labellable::Label")
      end

      # Saves all children of a given Labellable
      def save_children(id, labellable)
        @session.save(labellable.content, id)
      end

      # Loads all children of a given Labellable
      def load_children(id, labellable)
        content.loads(id) do |content|
          labellable[content] = content
        end
      end

      class Label < Persistor
        Model = Laboratory::Labellable::Label

      end
    end
  end
end
