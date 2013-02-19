module Lims::Core
  module Persistence
    module ContainerElement

      def save(element, container_id, position)
        #todo bulk save if needed
        element.each do |aliquot|
          save_as_aggregation(container_id, aliquot, position)
        end
      end

    end
  end
end
