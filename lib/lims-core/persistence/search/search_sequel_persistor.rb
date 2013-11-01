# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/search/search_persistor'
require 'lims-core/persistence/sequel/persistor'


module Lims::Core
  module Persistence
    # Not a search but a search persistor.
    class Search
      class SearchSequelPersistor < Search::SearchPersistor
        include Persistence::Sequel::Persistor

        def self.table_name
          :searches
        end

        def filter_attributes_on_load(attributes)
          filter_parameters = @session.unserialize(attributes[:filter_parameters])
          # The first key should be a symbol, @see persistence/comparison_filter.rb for example
          filter_parameters.rekey! { |k| k.to_sym }
          {
            :description => attributes[:description],
            :model => constant(attributes[:model]),
            :filter => Persistence.const_get(attributes[:filter_type]).new(filter_parameters)
          }
        end
        def filter_attributes_on_save(attributes, *args)
          filter = attributes[:filter]
          {
            :description => attributes[:description],
            :model => attributes[:model].name,
            :filter_type => filter.class.name.split('::').last,
            :filter_parameters => @session.serialize(filter.attributes)
          }
        end
      end
    end
  end
end
