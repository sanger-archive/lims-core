# Spec requirements
require 'spec_helper'

# Model requirements
require 'lims/core/organization/batch'

module Lims::Core::Organization
  describe Batch do
    def self.it_has_a(attribute, type=nil)
      it "responds to #{attribute}" do
        subject.should respond_to(attribute)
      end

      if type
        it "'s #{attribute} is a #{type}" do
          subject.send(attribute).andtap { |v| v.should be_a(type) }
        end
      end
    end

    def self.it_can_assign(attribute)
      it "can assign #{attribute}" do
        value = mock(:attribute)
        subject.send("#{attribute}=", value)
        subject.send(attribute).should == value
      end
    end

    it_can_assign :process
    it_has_a :process

    it "sets a process" do
      process = mock(:process)
      subject.process = process
      subject.process.should == process
    end
  end
end
