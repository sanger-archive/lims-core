# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/located_examples'
require 'laboratory/receptacle_examples'
require 'laboratory/labellable_examples'

# Model requirements
require 'lims/core/laboratory/tube'

module Lims::Core::Laboratory
  describe Tube  do

    def self.it_can_assign(attribute)
      it "can assign #{attribute}" do
        value = mock(:attribute)
        subject.send("#{attribute}=", value)
        subject.send(attribute).should == value
      end
    end

    it_behaves_like "located" 
    it_behaves_like "receptacle"
    it_behaves_like "labellable"

    it_can_assign :type
    it_can_assign :max_volume

    it "sets a type" do
      type = mock(:type)
      subject.type = type
      subject.type.should == type
    end

    it "sets a max volume" do
      max_volume = mock(:max_volume)
      subject.max_volume = max_volume
      subject.max_volume.should == max_volume
    end
  end
end
