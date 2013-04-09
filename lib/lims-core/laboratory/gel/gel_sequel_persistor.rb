require 'lims-core/laboratory/gel/gel_persistor'
require 'lims-core/persistence/sequel/persistor'
require 'lims-core/laboratory/container/container_sequel_persistor'
require 'lims-core/laboratory/container/container_element_sequel_persistor'

module Lims::Core
  module Laboratory
    # A gel persistor. It saves the gel's data to the DB.
    class Gel
      # A window persistor. It saves the window's data to the DB.
      class Window
        class WindowSequelPersistor< WindowPersistor
          include Persistence::Sequel::Persistor
          include Container::ContainerElementSequelPersistor

          def self.table_name
            :windows
          end

          def container_id_sym
            :gel_id
          end

        end 
      end
      #class Window

      class GelSequelPersistor < GelPersistor
        include Persistence::Sequel::Persistor
        include Container::ContainerSequelPersistor

        def self.table_name
          :gels
        end

        def container_id_sym
          :gel_id
        end
      end
    end
  end
end
