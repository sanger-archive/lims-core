# Spec requirements
require 'labware/spec_helper'
require 'labware/located_examples'

# Model requirements
require 'lims/core/labware/plate'

module Lims::Core::Labware
  describe Plate  do
    it_behaves_like "located" 
    it "has many wells"
  end
end
