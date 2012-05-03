# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/located_examples'
require 'laboratory/container_examples'
require 'laboratory/labellable_examples'

require 'laboratory/receptacle_examples'
# Model requirements
require 'lims/core/laboratory/plate'

module Lims::Core::Laboratory
  shared_examples "a valid plate" do
    it_behaves_like "located" 
    context "contains wells" do
      it_behaves_like "a container", Well
    end
  end

  shared_examples "a hash" do
    it "can be indexed with a symbol " do
      subject[:B3].should be_a(Plate::Well)
      aliquot = mock(:aliquot)
      subject[:B3] << aliquot
      subject[:B3].should include(aliquot)
    end

    it "can be indexed with a string " do
      subject["B3"].should be_a(Plate::Well)
      aliquot = mock(:aliquot)
      subject["B3"] << aliquot
      subject["B3"].should include(aliquot)
    end

    it "raise an exception if well doesn't exit" do
      expect { subject[:A13] }.to raise_error(Plate::IndexOutOfRangeError)
      expect { subject[:I1] }.to raise_error(Plate::IndexOutOfRangeError)
    end

    it "has a key for each wells" do
      subject.keys.size.should be == size
      subject.keys.should include("B3")
      subject.keys.should include("H12")
      subject.keys.should_not include("L2")
    end

    it { should respond_to(:values) }

    it "iterates as a Hash" do
      subject.each_with_index do |well, index|
        index.should be_a(String)
        well.should be_a(Plate::Well)
      end
    end

    it "'s values can be iterated an modified" do
      aliquot= mock(:aliquot)
      index = 3
      subject.values.each_with_index do |well, i|
        if i == index
          well << aliquot
          break
        end
      end
      subject[index].should include(aliquot)
    end

    it "can be iterated with index (String)" do
      aliquot= mock(:aliquot)
      index = "A3"
      subject.each_with_index do |well, i|
        if i == index
          well << aliquot
          break
        end
      end
      subject[index].should include(aliquot)
    end
  end

  describe Plate  do
    context "with 12x8 wells" do
      let(:row_number) { 8 }
      let(:column_number) { 12}
      let(:size) { row_number*column_number }
      subject { described_class.new(:column_number => column_number, :row_number =>row_number) }

      its(:row_number) {should == row_number }
      its(:column_number) { should == column_number }
      its(:size) { should eq(size) }

      it_behaves_like "a container", Plate::Well
      it_behaves_like "a hash"
      it_behaves_like "labellable"
    end
  end
  describe Plate::Well  do
    it "belongs  to a plate "  # contained by a plate
    it_behaves_like "receptacle"
  end
end
