module Lims::Core
  module Persistence
    module Sequel
      module PlateContainerElement
        include ContainerElement

        def element_dataset
          Lims::Core::Persistence::Sequel::Plate::Well::dataset(@session)
        end

        def container_id_sym
          :plate_id
        end

      end
    end
  end
end
