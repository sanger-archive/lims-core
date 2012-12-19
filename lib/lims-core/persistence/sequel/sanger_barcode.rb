require 'lims/core/persistence/sequel/persistor'
require 'lims/core/persistence/sanger_barcode'

module Lims::Core
  module Persistence
    module Sequel
      class SangerBarcode < Persistence::SangerBarcode
        include Sequel::Persistor

        def self.table_name
          :labels
        end
      end
    end
  end
end
