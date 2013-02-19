# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/batch'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      class Batch < Persistence::Batch
        include Sequel::Persistor

        def self.table_name
          :batches
        end
      end
    end
  end
end
