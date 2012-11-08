# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/filter'


module Lims::Core
  module Persistence
    # Filter  performing a && between all the pairs of a map.
    # Key being the field
    # Value : a value or a list of values to check real value against.
    class MultiCriteriaFilter <  Filter
      include Resource
      attribute :criteria, Hash, :required => true
      # For Sequel, keys needs to be a Symbol to be seen as column.
      # String are seen as 'value'
      def initialize(criteria)
        criteria = { :criteria => criteria } unless criteria.include?(:criteria)
        criteria[:criteria].rekey!{ |k| k.to_sym }
        super(criteria)
      end

      def call(persistor)
        persistor.multi_criteria_filter(criteria)
      end
    end

    class Persistor
      # @param [Hash] criteria a 
      # @return [Persistor] 
      def multi_criteria_filter(criteria)
        raise NotImplementedError "multi_criteria_filter methods needs to be implemented for subclass of Persistor"
      end
    end
  end
end

