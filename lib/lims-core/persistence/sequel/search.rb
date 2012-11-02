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
      end
    end
  end
end
