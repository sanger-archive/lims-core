require 'common'

require 'lims-core/labels/labellable'

module Lims::Core
  module Labels
    class Barcode2D
      include Labellable::Label
      Type = "2d-barcode"
    end
  end
end
