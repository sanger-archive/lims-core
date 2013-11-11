require 'actions/spec_helper'

require 'lims-core/actions/action_group'
module Lims::Core
  module Actions
    module TestActionGroup
      class Action
        include  Actions::Action
      end
      class ActionGroup
        include Actions::ActionGroup
      end
      describe ActionGroup do
        context "with 2 actions" do
          let(:store) { Lims::Core::Persistence::Store.new }
          let(:user) { mock :user }
          let(:application) { "test" }
          let(:action_parameters) { {:user => user, :application => application, :store => store } }
          let!(:action1) { Action.new(action_parameters).tap do |action|
            end }
          let!(:action2) { Action.new(action_parameters).tap do |action|
            end }

          subject{ ActionGroup.new(action_parameters.merge(:actions => [action1, action2])) do |action, session|
            end
          }

          it "executes both action" do
            action1.should_receive(:_call_in_session) { :result_1 }
            action2.should_receive(:_call_in_session) { :result_2 }

            subject.call();
            subject.result.should == [:result_1, :result_2]
          end
        end
      end
    end
  end
end
