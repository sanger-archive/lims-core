require 'lims/core/laboratory/container'
require 'lims/core/laboratory/well'

module Lims::Core
  module Laboratory
    # A plate is a plate as seen in a laboratory, .i.e
    # a rectangular bits of platics with wells and some 
    # readable labels on it.
    # TODO add label behavior
    class Plate 
     include Container
     contains Well
    end
  end
end
