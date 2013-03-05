require 'lims/core/persistence/gel'
require 'lims/core/persistence/sequel/persistor'
require 'lims/core/persistence/sequel/container'
require 'lims/core/persistence/sequel/container_element'

module Lims::Core
  module Persistence
    module Sequel
      # A gel persistor. It saves the gel's data to the DB.
      class Gel < Persistence::Gel
        include Sequel::Persistor
        include Container

        module GelContainerElement
          include ContainerElement

          def element_dataset
            Lims::Core::Persistence::Sequel::Gel::Window::dataset(@session)
          end

          def container_id_sym
            :gel_id
          end

        end

        # A window persistor. It saves the window's data to the DB.
        class Window < Persistence::Gel::Window
          include Sequel::Persistor
          include GelContainerElement

          def self.table_name
            :windows
          end

        end 
        #class Window

        def self.table_name
          :gels
        end

        def container_id_sym
          :gel_id
        end

        def element_dataset
          Window::dataset(@session)
        end
      end
    end
  end
end
