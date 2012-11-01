#vi: ts=2 sw=2 et
require 'common'

require 'lims-core/resource'
require 'lims-core/persistence/filter'

module Lims::Core
  module Persistence
    # base class handling searches. A Search represent a set of parameters 
    # which when executed returns a set of similar object (.i.e the same class).
    # A search is savable.
    class Search
      include Resource
      attribute :model, Class, :required => true, :initializable => true, :writer => :private
      attribute :filter, Filter, :required => true, :initializable => true, :writer => :private

      # Main method. Take an session an return an filtered persistor.
      # @session [Session]
      # @return [Persistor]
      def call(session)
        filter.call(session.persistor_for(@model))
      end
    end
  end
end

