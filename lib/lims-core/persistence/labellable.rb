require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/labellable'

module Lims::Core
  module Persistence
    class Labellable < Persistor
      Model = Laboratory::Labellable

      # ke4 TODO add contents related methods?
      def content
        @session.send("Labellable::Content")
      end

      # Saves all children of a given Labellable
      def save_children(id, labellable)
      end

      # Loads all children of a given Labellable
      def load_children(id, labellable)
      end

      def content
      end

#      class Content < Persistor
#        Model = Laboratory::Labellable::Content
#        
#      end
    end
  end
end
