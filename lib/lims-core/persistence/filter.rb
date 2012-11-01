#vi: ts=2 sw=2 et
require 'common'

module Lims::Core
  module Persistence
    # @abstract Base class of all filters.
    # A filter acts on persistors and can be chained.
    # Note: This class is not really usefull in a *Ruby world* and is mainly
    # here for documentation.
    class Filter
      # Transform a persistor to a "filtered persistor"
      # The filtered persistor loading only the filtered object.
      # Note that the actual implementation of the filter depends on the 
      # *type* of the persistor (Sequel for example).
      # @param persistor [Persistence::Persistor]
      # @return [Persistor]
      def call(persistor)
        raise NotImplementedError
      end
    end
  end
end

