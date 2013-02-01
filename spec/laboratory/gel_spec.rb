# Spec requirements
require 'laboratory/located_examples'
require 'laboratory/container_examples'
require 'laboratory/labellable_examples'

require 'laboratory/receptacle_examples'

# Model requirements
require 'lims/core/laboratory/gel'

module Lims::Core::Laboratory
  shared_examples "a valid gel" do
    it_behaves_like "located" 
    context "contains windows" do
      it_behaves_like "a container", Gel::Window
    end
  end

  describe Gel do
    context "with 12x8 windows" do
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12}
      let(:size) { number_of_rows*number_of_columns }

      let(:container) { Gel::Window }
      let(:error_container_does_not_exists) { Gel::IndexOutOfRangeError }

      subject { described_class.new(:number_of_columns => number_of_columns, :number_of_rows =>number_of_rows) }

      its(:number_of_rows) {should == number_of_rows }
      its(:number_of_columns) { should == number_of_columns }
      its(:size) { should eq(size) }

      it_behaves_like "a valid gel"
      it_behaves_like "a hash"
      it_behaves_like "labellable"
    end
  end

  describe Gel::Window do
    it "belongs to a gel "  # contained by a gel
    it_behaves_like "receptacle"
  end
end
