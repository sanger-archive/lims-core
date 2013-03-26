# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/located_examples'
require 'laboratory/container_examples'
require 'labels/labellable_examples'

require 'laboratory/receptacle_examples'
# Model requirements
require 'lims-core/labels/labellable'

module Lims::Core::Labels
  shared_examples_for "label creator" do |type, klass|
    it "should create the correct label class" do
      described_class.new(:type => type).should be_a klass
    end
  end
  describe Labellable  do
    let(:barcode) { mock(:barcode) do |barcode| 
        barcode.stub(:value) {"12345"}
        barcode.stub(:type) { "barcode 1d" }
      end
    }
    context "to be valid" do
      let(:name) { "my plate" }
      let(:type) { "plate" }
      let(:create_parameters) { {:name => name, :type => type} }
      let(:excluded_parameters) { [] }
      subject { described_class.new(create_parameters - excluded_parameters) }
      it  "valid" do
        subject.valid?.should == true
      end
      it_behaves_like "requires", :name
      it_behaves_like "requires", :type
    end
    it_behaves_like "a container", Labellable::Label
    context "a hash" do

      it "can be indexed with a string " do
        subject["barcode"].should be_nil
        subject["barcode"] = barcode
        subject["barcode"].should == barcode
      end

      it { should respond_to(:values) }
      it { should respond_to(:positions) }

      it "iterates as a Hash" do
        subject.each do |position, label|
          index.should be_a(String)
          label.should be_a(Labellable::Label)
        end
      end

      it "can be iterated with index (String)" do
        subject["barcode"] = barcode
        subject.each_with_index do |label, position|
        end
      end
    end
  end

  describe Labellable::Label do
    it_behaves_like "label creator", "sanger-barcode", SangerBarcode
    it_behaves_like "label creator", "2d-barcode", Barcode2D
    it_behaves_like "label creator", "ean13-barcode", EAN13Barcode
  end
end
