#vi: ts=2 sw=2 et
require 'common'

module Lims::Core
  module Persistence
    # Base class of all filters.
    # A fitler acts on persistors and can be chained.
    class Filter
      # Transform a persistor to a "filtered persistor"
      # The filtered persistor loading only the filtered object.
      # Note that the actual implementation of the filter depends on the 
      # *type* of the persistor (Sequel for example).
      # @persistor [Persistence::Persistor]
      # @return [Persistor]
      def call(persistor)
        raise NotImplementedError
      end
    end
  end
end

