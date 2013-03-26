# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/persistor'
require 'lims-core/laboratory/container/container_persistor'
require 'lims-core/laboratory/container/container_element_persistor'
require 'lims-core/laboratory/plate'

module Lims::Core
  module Laboratory

    # Base for all Plate persistor.
    # Real implementation classes (e.g. Sequel::Plate) should
    # include the suitable persistor.
    class Plate::PlatePersistor < Persistence::Persistor
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
      class Well < Persistence::Persistor
        Model = Laboratory::Plate::Well

        include ContainerElement

      end
    end
  end
end
