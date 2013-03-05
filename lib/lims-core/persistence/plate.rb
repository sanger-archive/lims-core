# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/persistor'
require 'lims/core/persistence/container'
require 'lims/core/persistence/container_element'
require 'lims/core/laboratory/plate'

module Lims::Core
  module Persistence

    # Base for all Plate persistor.
    # Real implementation classes (e.g. Sequel::Plate) should
    # include the suitable persistor.
    class Plate < Persistor
      Model = Laboratory::Plate

      include Container

      # calls the correct element method
      def element
        well
      end

      def well
        @session.send("Plate::Well")
      end

      # Base for all Well persistor.
      # Real implementation classes (e.g. Sequel::Well) should
      # include the suitable persistor.
      class Well < Persistor
        Model = Laboratory::Plate::Well

        include ContainerElement

      end
    end
  end
end
