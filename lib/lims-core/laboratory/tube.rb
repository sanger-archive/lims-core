require 'common'
require 'lims/core/resource'
require 'lims/core/laboratory/receptacle.rb'

module Lims::Core
  module Laboratory
    # Piece of laboratory. 
    # Can have something in it and probably a label or something to identifiy it.
    class Tube
      include Resource
      include Receptacle
    end
  end
end
