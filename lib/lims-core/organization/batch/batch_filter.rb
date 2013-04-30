# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'lims-core/persistence/multi_criteria_filter'
require 'lims-core/organization/batch'
require 'lims-core/resource'

module Lims::Core
  module Persistence
    class BatchFilter < Persistence::Filter
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
        persistor.batch_filter(criteria)
      end
    end
  end

  class Persistor
    # @param [Hash] criteria 
    # @return [Persistor] 
    def batch_filter(criteria)
      raise NotImplementedError "batch_filter methods needs to be implemented for subclass of Persistor"
    end
  end
end
