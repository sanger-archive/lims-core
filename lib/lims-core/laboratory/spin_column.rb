require 'lims/core/resource'
require 'lims/core/laboratory/receptacle.rb'

module Lims::Core
  module Laboratory
    # Piece of labware. 
    # Can have something on it.
    # It can have a label (barcode) to identify it.
    class SpinColumn
      include Resource
      include Receptacle
    end
  end
end
