require 'lims-core/persistence/filter'
require 'lims-core/resource'


module Lims::Core
  module Persistence
    # Filter performing a comparison between the resource field's value 
    # and a given value.
    # Key being the name of the resource's field and the value is a Hash.
    # The key of the hash is a comparison operator
    # and the value is the given value the filter do the comparison against.
    #
    # @example
    #
    # "model": "kit",
    # "criteria": {
    #     "comparison": {
    #         "expires": {
    #             ">=": "2013-04-24"
    #         }
    #     }
    # }
    #
    # Will look for all kits expires after the given date ("2013-04-24").
    #
    class ComparisonFilter <  Filter
      include Resource

      NOT_IN_ROOT = 1

      attribute :criteria, Hash, :required => true
      attribute :model, String, :required => true
      # For Sequel, keys needs to be a Symbol to be seen as column.
      # String are seen as 'value'
      def initialize(criteria)
        criteria = { :criteria => criteria } unless criteria.include?(:criteria)
        criteria[:criteria].rekey!{ |k| k.to_sym }
        super(criteria)
      end

      def call(persistor)
        persistor.comparison_filter(criteria[:comparison], model)
      end
    end
  end

  class Persistor
    # @param [Hash] criteria a 
    # @return [Persistor] 
    def comparison_filter(criteria, model)
      raise NotImplementedError, "comparison_filter methods needs to be implemented for subclass of Persistor"
    end
  end
end
