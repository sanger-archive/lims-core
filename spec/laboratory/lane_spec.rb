# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/receptacle_examples'

# Model requirements
require 'lims-core/laboratory/flowcell'

module Lims::Core::Laboratory
  describe Flowcell::Lane  do
    it "belongs  to a flowcell "  # contained by a flowcell
    it_behaves_like "receptacle"
  end
end
