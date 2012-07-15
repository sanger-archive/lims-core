# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

#Model requirements
require 'lims/core/actions/create_plate'


module Lims::Core
  module Actions
    describe CreatePlate do
      context "with a valid store" do
        let (:store) { Persistence::Store.new }
        include_context "create object"
        let(:user) { mock(:user) }
        let(:application) { "Test create plate" }

        let(:dimensions) {{ :row_number => 8, :column_number => 12 }}
        subject do CreatePlate.new(:store => store, :user => user, :application => application)  do |a,s|
          a.ostruct_update(dimensions)
        end
        end
        it_behaves_like "an action"
        it "create a plate when called" do
          result = subject.call()
          result.should be_a Hash
          
          plate = result[:plate]
          plate.row_number.should == dimensions[:row_number]
          plate.column_number.should == dimensions[:column_number]

          result[:uuid].should == uuid
        end
      end
    end
  end
end
