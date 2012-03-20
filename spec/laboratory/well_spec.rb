# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/receptacle_examples'

# Model requirements
require 'lims/core/laboratory/well'

module Lims::Core::Laboratory
  describe Well  do
    it "belongs  to a plate "  # contained by a plate
    it_behaves_like "receptacle"
  end
end
