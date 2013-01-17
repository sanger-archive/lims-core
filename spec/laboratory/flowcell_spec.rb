# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/located_examples'
require 'laboratory/container_examples'
require 'laboratory/labellable_examples'

require 'laboratory/receptacle_examples'

# Model requirements
require 'lims/core/laboratory/flowcell'

module Lims::Core::Laboratory
  shared_examples "contains lanes" do
    its(:size) { should eq(number_of_lanes) } 
    it_behaves_like "a container", Flowcell::Lane

    it "can have a content put in one lane" do
      aliquot = Aliquot.new
      subject[0] << aliquot
      subject[0].should include(aliquot)
    end
    it "can have an aliquot added in one lane" do
      aliquot = Aliquot.new
      subject[0] << aliquot
      subject[0].should include(aliquot)
    end
  end

  describe Flowcell  do
    subject {described_class.new(:number_of_lanes => number_of_lanes)}
    
    context "of type MiSeq" do
      let (:number_of_lanes) { 1 }
      it_behaves_like "located" 
      it_behaves_like "contains lanes"
      it_behaves_like "labellable"
    end

    context "of type HiSeq" do
      let (:number_of_lanes) { 8 }
      it_behaves_like "located" 
      it_behaves_like "contains lanes"
      it_behaves_like "labellable"
    end
  end
  
  describe Flowcell::Lane  do
    it "belongs  to a flowcell "  # contained by a flowcell
    it_behaves_like "receptacle"
  end
end
