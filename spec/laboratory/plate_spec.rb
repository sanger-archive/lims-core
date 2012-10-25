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
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12}
      let(:size) { number_of_rows*number_of_columns }
      subject { described_class.new(:number_of_columns => number_of_columns, :number_of_rows =>number_of_rows) }

      its(:number_of_rows) {should == number_of_rows }
      its(:number_of_columns) { should == number_of_columns }
      its(:size) { should eq(size) }

      it_behaves_like "a container", Plate::Well
      it_behaves_like "a hash"
      it_behaves_like "labellable"

      context "#pools" do
        it "each well belongs to only one pool" do
          pools = subject.pools
          pools.should_not be_empty

          # wells appears only once
          pooled_wells = pools.values.flatten(1)
          pooled_wells.size.should == pooled_wells.uniq.size
        end

        it "each well belong to at least one pool" do
          pooled_wells = Set.new(subject.pools.values.flatten(1))

          subject.each_with_index do |well, name|
            next if well.empty?
            pooled_wells.should include(name)
          end

        end

        context "#stub" do
          it "are arranged by column" do
            pools = subject.pools

            pools.size.should == subject.number_of_columns
            pools.keys.should == [1, 2, 3, 4, 5, 6, 7 ,8, 9 , 10, 11, 12]
            pools[1].should == %w(A1 B1 C1 D1 E1 F1 G1 H1)
          end
        end
      end

    end
  end
  describe Plate::Well  do
    it "belongs  to a plate "  # contained by a plate
    it_behaves_like "receptacle"
  end
end
