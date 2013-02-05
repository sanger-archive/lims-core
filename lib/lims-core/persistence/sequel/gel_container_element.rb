module Lims::Core
  module Persistence
    module Sequel
      module GelContainerElement
        include ContainerElement

        def element_dataset
          Lims::Core::Persistence::Sequel::Gel::Window::dataset(@session)
        end

        def container_id_sym
          :gel_id
        end

      end
    end
  end
end
