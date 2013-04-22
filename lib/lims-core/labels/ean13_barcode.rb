require 'common'
require 'lims-core/labels/labellable'

module Lims::Core
  module Labels
    class EAN13Barcode
      include Labellable::Label
      Type = "ean13-barcode"
    end
  end
end
