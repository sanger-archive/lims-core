require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      # Implementes filter methods needed by persitors.
      module Filters
        def multi_criteria_filter(criteria)
          self.class.new(self, dataset.filter(criteria))
        end
      end
    end
  end
end

