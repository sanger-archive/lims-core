# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

#Model requirements
require 'lims/core/actions/create_plate'

require 'lims/core/persistence/store'

module Lims::Core
  module Actions
    describe CreatePlate do
      context "with a valid store" do
        # @todo special test session class ?
        before { Persistence::Session.any_instance.stub(:save)   }
        let (:store) { Persistence::Store.new }
        let(:user) { mock(:user) }
        let(:application) { "Test create plate" }

        let(:dimensions) {{ :row_number => 8, :column_number => 12 }}
        subject do CreatePlate.new(:store => store, :user => user, :application => application)  do |a,s|
          a.ostruct_update(dimensions)
        end
        end
        it_behaves_like "an action"
        it "create a plate when called" do
          plate = subject.call()
          plate.should be_a Laboratory::Plate
          plate.row_number.should == dimensions[:row_number]
          plate.column_number.should == dimensions[:column_number]
        end
      end
    end
  end
end
