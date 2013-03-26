require 'laboratory/container_examples'
require 'labels/labellable_examples'
require 'lims-core/laboratory/tube_rack'

module Lims::Core::Laboratory
  shared_examples "a tube rack hash" do
    it "can be indexed with a symbol " do
      subject[:B5].should be_a(Tube)
    end

    it "can be indexed with a string " do
      subject["B5"].should be_a(Tube)
    end

    it "raise an exception if the position in the rack doesn't exit" do
      expect { subject[:A13] }.to raise_error(TubeRack::IndexOutOfRangeError)
      expect { subject[:I1] }.to raise_error(TubeRack::IndexOutOfRangeError)
    end

    it "has a key for each position" do
      subject.keys.size.should be == size
      subject.keys.should include("B3")
      subject.keys.should include("H12")
      subject.keys.should_not include("L2")
    end

    it { should respond_to(:keys) }
    it { should respond_to(:values) }

    it "iterates as a Hash" do
      subject.each_with_index do |element, index|
        index.should be_a(String)
        [NilClass, Tube].should include(element.class)
      end
    end
  end


  describe TubeRack do
    context "with 12x8 available placements for tubes" do
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12 }
      let(:size) { number_of_rows * number_of_columns }
      subject { 
        described_class.new(:number_of_columns => number_of_columns, :number_of_rows => number_of_rows).tap do |rack|
          rack[:A1] = Lims::Core::Laboratory::Tube.new
          rack[:B5] = Lims::Core::Laboratory::Tube.new
          rack[:E3] = Lims::Core::Laboratory::Tube.new
        end
      }

      its(:number_of_rows) { should == number_of_rows }
      its(:number_of_columns) { should == number_of_columns }

      it "cannot store something else than tubes" do
        expect { subject[:A2] = "something" }.to raise_error(ArgumentError)
      end

      it "cannot replace a tube if it already exists in the rack" do
        expect { subject[:A1] = Lims::Core::Laboratory::Tube.new }.to raise_error(TubeRack::RackPositionNotEmpty)
      end

      it_behaves_like "a container", Tube
      it_behaves_like "a tube rack hash"
      it_behaves_like "labellable"
    end
  end
end

