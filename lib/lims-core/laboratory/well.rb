require 'lims/core/laboratory/receptacle.rb'
module Lims::Core

  module Laboratory
    # The well of a {Plate}. 
    # Contains some chemical substances.
    class Well
      include Receptacle
    end
  end
end
