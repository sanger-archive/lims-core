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
        subject { CreatePlate.new(dimensions.merge({:store => store, :user => user, :application => application})) }
        it_behaves_like "an action"
        it "create a plate when called" do
          subject.call().should be_a Laboratory::Plate
        end
      end
    end
  end
end
