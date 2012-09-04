# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/located_examples'
require 'laboratory/container_examples'
require 'laboratory/labellable_examples'

require 'laboratory/receptacle_examples'

# Model requirements
require 'lims/core/laboratory/flowcell'

module Lims::Core::Laboratory
  shared_context "contains lanes" do
    subject {described_class.new(:number_of_lanes => number_of_lanes)}
    its(:size) { should eq(number_of_lanes) } 
    it_behaves_like "a container", Flowcell::Lane

    it "can have a content put in one lane" do
      aliquot = mock(:aliquot)
      subject[1] << aliquot
      subject[1].should include(aliquot)
    end
    it "can have an aliquot added in one lane" do
      aliquot = mock(:aliquot)
      subject[1] << aliquot
      subject[1].should include(aliquot)
    end
  end

  describe Flowcell  do
    let(:miseq_number_of_lanes) { 1 }
    let(:hiseq_number_of_lanes) { 8 }

    let(:number_of_lanes) { miseq_number_of_lanes }
    it_behaves_like "located" 
    context do
      include_context "contains lanes"   
    end

    it_behaves_like "labellable"

    let(:number_of_lanes) { hiseq_number_of_lanes }
    it_behaves_like "located" 
    context do
      include_context "contains lanes"   
    end

    it_behaves_like "labellable"
  end

  describe Flowcell::Lane  do
    it "belongs  to a flowcell "  # contained by a flowcell
    it_behaves_like "receptacle"
  end
end
