# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/filter'
require 'lims-core/resource'


module Lims::Core
  module Laboratory
    # Filter  performing a && between all the pairs of a map.
    # Key being the field
    # Value can be either a String, an Array  or a Hash.
    # Strings and Arrays are normal filters, whereas Hashes
    # correspond to a joined search. The criteria will apply to the 
    # joined object corresponding to the key.
    # @example
    #   {
    #     :status => [:pending, :in_progress],
    #     :item => {
    #       :status => [:pending],
    #       :uuid => <plate_uuid>
    #     }
    #    }
    #   Will look for all the orders in pending or in progress status
    #   *holding* a plate with a pending status.
    #    
    class LabelFilter < Filter 
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
        persistor.label_filter(criteria)
      end
    end

    class Persistor
      # @param [Hash] criteria a 
      # @return [Persistor] 
      def label_filter(criteria)
        raise NotImplementedError "multi_criteria_filter methods needs to be implemented for subclass of Persistor"
      end
    end
  end
end

