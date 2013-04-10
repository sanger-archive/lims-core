require 'common'
require 'lims-core/resource'
require 'lims-core/laboratory/receptacle.rb'

module Lims::Core
  module Laboratory
    # Piece of laboratory. 
    # Can have something in it and probably a label or something to identifiy it.
    class Tube
      include Resource
      include Receptacle
      # Type contains the actual type of the tube, for example Eppendorf.
      attribute :type, String, :required => false
      # Store the maximum volume a tube can hold in ml.
      attribute :max_volume, Numeric, :gte => 0, :required => false
    end
  end
end
