# Spec requirements
require 'persistence/spec_helper'

# Model requirements
require 'lims-core/persistence/search'

module Lims::Core
  module Persistence
    describe Search do
      context "to be valid" do
        let(:filter) { mock(:filter) }
        let(:model) { mock(:model) }
        let(:create_parameters) {  {:filter => filter, :model => model } }
        it "requires a model" do
          described_class.new(create_parameters - [:model])
          subject.valid?.should == false
        end

        it "requires a filter" do
          described_class.new(create_parameters - [:filter])
          subject.valid?.should == false
        end

        it "requires a model and a filter" do
          described_class.new(create_parameters)
          subject.valid?
          puts subject.errors[:model].inspect
          subject.valid?.should == true
        end
      end

      context "valid" do
        xit "returns a persistor" do
          session = mock(:session)
          #session.should_receive()
          subject.persistor(session).should
        end
      end
    end
  end
end
