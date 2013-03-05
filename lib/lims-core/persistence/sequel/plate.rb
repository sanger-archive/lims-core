# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/plate'
require 'lims/core/persistence/sequel/persistor'
require 'lims/core/persistence/sequel/container'
require 'lims/core/persistence/sequel/container_element'

module Lims::Core
  module Persistence
    module Sequel
      # Not a plate but a plate persistor.
      class Plate < Persistence::Plate
        include Sequel::Persistor
        include Container

        module PlateContainerElement
          include ContainerElement

          def element_dataset
            Lims::Core::Persistence::Sequel::Plate::Well::dataset(@session)
          end

          def container_id_sym
            :plate_id
          end

        end

        # Not a well but a well {Persistor}.
        class Well < Persistence::Plate::Well
          include Sequel::Persistor
          include PlateContainerElement

          def self.table_name
            :wells
          end

        end #class Well

        def self.table_name
          :plates
        end

        def container_id_sym
          :plate_id
        end

        def element_dataset
          Well::dataset(@session)
        end
      end
    end
  end
end
