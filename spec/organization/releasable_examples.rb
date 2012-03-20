# Spec requirements
require 'organization/spec_helper'

module Lims::Core::Organization
  shared_examples "releasable" do

    xit "is releasable" do
       described_class.new.is_a?(Releasable).should eq true
    end

    context "when it's been released" do
      it "should have an accession number"
      it "can have it's accession number modified"
    end

    context "to be releasable" do
      it "has data release attribute set"
      it "has data release policy set"
    end

    context  "to be sent to EBI" do
      it "corresponds to  an XML file" #might be xml generator 
    end
  end
end
