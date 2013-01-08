require 'common'

require 'lims-core/laboratory/labellable'

module Lims::Core
  module Laboratory
    class SangerBarcode
      include Labellable::Label
      Type = "sanger-barcode"
    end
  end
end
