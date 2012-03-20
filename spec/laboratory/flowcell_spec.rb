# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/located_examples'
require 'laboratory/container_examples'
require 'laboratory/labellable_examples'

require 'laboratory/receptacle_examples'

# Model requirements
require 'lims/core/laboratory/flowcell'

module Lims::Core::Laboratory
  describe Flowcell  do
    it_behaves_like "located" 
    context "contains lanes" do
      it_behaves_like "a container", Flowcell::Lane
      its(:size) { should eq(8) } 

      it "can have a content put in one lane" do
        aliquot = mock(:aliquot)
        subject[0] << aliquot
        subject[0].should include(aliquot)
      end
      it "can have an aliquot added in one lane" do
        aliquot = mock(:aliquot)
        subject[0] << aliquot
        subject[0].should include(aliquot)
      end
    end
    it_behaves_like "labellable"

  end
  describe Flowcell::Lane  do
    it "belongs  to a flowcell "  # contained by a flowcell
    it_behaves_like "receptacle"
  end
end
