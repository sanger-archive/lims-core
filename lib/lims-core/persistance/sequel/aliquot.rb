# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistance/aliquot'
require 'lims/core/persistance/sequel/persistor'

module Lims::Core
  module Persistance
    module Sequel
      # Not a aliquot but a aliquot persistor.
      class Aliquot < Persistance::Aliquot
        include Sequel::Persistor
        def self.table_name
          :aliquots
        end
      end
    end
  end
end
