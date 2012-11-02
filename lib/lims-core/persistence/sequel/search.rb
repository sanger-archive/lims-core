# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/search'
require 'lims/core/persistence/sequel/persistor'


module Lims::Core
  module Persistence
    module Sequel
      # Not a search but a search persistor.
      class Search < Persistence::Search::Persistor
        include Sequel::Persistor

        def self.table_name
          :searches
        end

        def filter_attributes_on_load(attributes)
          debugger
          {
            :model => constant(attributes[:model]),
            :filter => Persistence.const_get(attributes[:filter_type]).new(Marshal.load(attributes[:filter_parameters]))
          }
        end
        def filter_attributes_on_save(attributes, *args)
          debugger
            filter = attributes[:filter]
          {
            :model => attributes[:model].name,
            :filter_type => filter.class.name.split('::').last,
            :filter_parameters => Marshal.dump(filter.attributes)
          }
        end
      end
    end
  end
end
