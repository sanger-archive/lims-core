# Spec requirements
require 'laboratory/spec_helper'

# Model requirements
require 'lims/core/laboratory/aliquot'

module Lims::Core::Laboratory
  describe Aliquot do
    context "to be valid" do
      let (:aliquot) {Aliquot.new(:quantity=>10)}

      xit "must have everything needed" do
        aliquot.valid?.should be_true
      end
      it "must have an owner"
      xit "must have a type" do
        # this is an example to mostly test yard-rspec.
        aliquot.type=nil
        aliquot.valid?.should be_false
      end
      it "must have a quantity" do
      pending "we might use nil quanity for unknown quantity" do
        aliquot.quantity=nil
        aliquot.valid?.should eq false
      end
      end

      xit "must have a positive quantity" do
        aliquot.quantity=-5
        aliquot.valid?.should  be_false
      end

      it "should be in a receptacle"
      it "can't be empty"
    end
  end
end
