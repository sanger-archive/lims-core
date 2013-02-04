require 'common'

require 'lims-core/laboratory/labellable'

module Lims::Core
  module Laboratory
    class Barcode2D
      include Labellable::Label
      Type = "2d-barcode"
    end
  end
end
