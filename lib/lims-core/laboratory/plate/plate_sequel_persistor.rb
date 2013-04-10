# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/laboratory/plate/plate_persistor'
require 'lims-core/persistence/sequel/persistor'
require 'lims-core/laboratory/container/container_sequel_persistor'
require 'lims-core/laboratory/container/container_element_sequel_persistor'

module Lims::Core
  module Laboratory
    # Not a plate but a plate persistor.
    class Plate
      # Not a well but a well {Persistor}.
      class Well
        class WellSequelPersistor < Plate::Well::WellPersistor
          include Persistence::Sequel::Persistor
          include Container::ContainerElementSequelPersistor

          def self.table_name
            :wells
          end

          def container_id_sym
            :plate_id
          end

        end
      end #class Well

      class PlateSequelPersistor < PlatePersistor
        include Persistence::Sequel::Persistor
        include Container::ContainerSequelPersistor

        def self.table_name
          :plates
        end

        def container_id_sym
          :plate_id
        end
      end
    end
  end
end
