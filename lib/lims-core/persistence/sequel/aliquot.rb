# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/aliquot'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      # Not a aliquot but a aliquot persistor.
      class Aliquot < Persistence::Aliquot
        include Sequel::Persistor
        def self.table_name
          :aliquots
        end
      end
    end
  end
end
