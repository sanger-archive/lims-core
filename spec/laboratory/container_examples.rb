# Spec requirements
require 'laboratory/spec_helper'

shared_examples "a container" do |contained|
  it { subject.should respond_to(:each) }
  it { subject.should respond_to(:size) }

  it "has many 'contained' objects" do
    subject.each do |content|
      content.should be_a(contained) unless content.nil?
    end
  end
end

module Lims::Core::Laboratory
  shared_examples "a hash" do
    it "can be indexed with a symbol " do
      subject[:B3].should be_a(container)
      aliquot = Aliquot.new
      subject[:B3] << aliquot
      subject[:B3].should include(aliquot)
    end

    it "can be indexed with a string " do
      subject["B3"].should be_a(container)
      aliquot = Aliquot.new
      subject["B3"] << aliquot
      subject["B3"].should include(aliquot)
    end

    it "raise an exception if container doesn't exit" do
      expect { subject[:A13] }.to raise_error(error_container_does_not_exists)
      expect { subject[:I1] }.to raise_error(error_container_does_not_exists)
    end

    it "has a key for each wells" do
      subject.keys.size.should be == size
      subject.keys.should include("B3")
      subject.keys.should include("H12")
      subject.keys.should_not include("L2")
    end

    it { should respond_to(:values) }

    it "iterates as a Hash" do
      subject.each_with_index do |w, index|
        index.should be_a(String)
        w.should be_a(container)
      end
    end

    it "'s values can be iterated an modified" do
      aliquot= Aliquot.new
      index = 3
      subject.values.each_with_index do |w, i|
        if i == index
          w << aliquot
          break
        end
      end
      subject[index].should include(aliquot)
    end

    it "can be iterated with index (String)" do
      aliquot= Aliquot.new
      index = "A3"
      subject.each_with_index do |w, i|
        if i == index
          w << aliquot
          break
        end
      end
      subject[index].should include(aliquot)
    end
  end
end
