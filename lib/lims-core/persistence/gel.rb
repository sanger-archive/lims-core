require 'lims/core/persistence/persistor'
require 'lims/core/persistence/container'
require 'lims/core/persistence/container_element'
require 'lims/core/laboratory/gel'

module Lims::Core
  module Persistence

    # Base for all Gel persistor.
    # Real implementation classes (e.g. Sequel::Gel) should
    # include the suitable persistor.
    class Gel < Persistor
      Model = Laboratory::Gel

      include Container

      # calls the correct element method
      def element
        window
      end

      def window
        @session.send("Gel::Window")
      end

      # Base for all Window persistor.
      # Real implementation classes (e.g. Sequel::Window) should
      # include the suitable persistor.
      class Window < Persistor
        Model = Laboratory::Gel::Window

        include ContainerElement

      end
    end
  end
end
