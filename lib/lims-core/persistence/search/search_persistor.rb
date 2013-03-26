#vi: ts=2 sw=2 et
require 'common'

require 'lims-core/resource'
require 'lims-core/persistence/persistor'
require 'lims-core/persistence/filter'

# We need to load all the possible filter to be able load them by name.
require_all('*filter')

module Lims::Core
  module Persistence
    # base class handling searches. A Search represent a set of parameters 
    # which when executed returns a set of similar object (.i.e the same class).
    # A search is savable.
    class Search
      include Resource
      attribute :description, String, :required => true, :initializable => true, :write => :private
      attribute :model, Class, :required => true, :initializable => true, :writer => :private
      attribute :filter, Filter, :required => true, :initializable => true, :writer => :private

      # Main method. Take an session an return an filtered persistor.
      # @param [Session]
      # @return [Persistor]
      def call(session)
        filter.call(session.persistor_for(@model))
      end

      # Base persistor for Search object.
      # It should be called Persistence::Search but, this is 
      # already taken by the main Search class.
      class SearchPersistor < Persistence::Persistor
        Model = Persistence::Search
      end
    end
  end
end

