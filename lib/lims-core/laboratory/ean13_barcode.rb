require 'common'
require 'lims-core/laboratory/labellable'

module Lims::Core
  module Laboratory
    class EAN13Barcode
      include Labellable::Label
      Type = "ean13-barcode"
    end
  end
end
