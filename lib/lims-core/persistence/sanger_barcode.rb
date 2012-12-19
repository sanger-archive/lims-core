require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  module Persistence

    class SangerBarcode < Persistor
      Model = Laboratory::SangerBarcode
    end
  end
end
