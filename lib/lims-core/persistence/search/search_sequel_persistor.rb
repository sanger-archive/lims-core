# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/search/search_persistor'
require 'lims-core/persistence/sequel/persistor'


module Lims::Core
  module Persistence
    # Not a search but a search persistor.
    class Search::SearchSequelPersistor < Search::SearchPersistor
      include Sequel::Persistor

      def self.table_name
        :searches
      end

      def filter_attributes_on_load(attributes)
        {
          :description => attributes[:description],
          :model => constant(attributes[:model]),
          :filter => Persistence.const_get(attributes[:filter_type]).new(Marshal.load(attributes[:filter_parameters]))
        }
      end
      def filter_attributes_on_save(attributes, *args)
        filter = attributes[:filter]
        {
          :description => attributes[:description],
          :model => attributes[:model].name,
          :filter_type => filter.class.name.split('::').last,
          :filter_parameters => Marshal.dump(filter.attributes)
        }
      end
    end
  end
end
