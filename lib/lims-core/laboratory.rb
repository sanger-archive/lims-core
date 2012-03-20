#vi: ts=2 sw=2 et
require 'lims/core/laboratory/plate.rb'
require 'lims/core/laboratory/tube.rb'
require 'lims/core/laboratory/flowcell.rb'

require 'lims/core/laboratory/aliquot'
require 'lims/core/laboratory/sample'
require 'lims/core/laboratory/tag'

module Lims::Core
  # Things used/found in the lab. Includes pure laboratory (inert things as {Plate plates}, {Tube tubes})
  # and chemical one (as {Aliquot aliquots}, {Sample samples}).
  module Laboratory
  end
end
