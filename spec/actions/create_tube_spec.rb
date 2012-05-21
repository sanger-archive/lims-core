# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

#Model requirements
require 'lims/core/actions/create_tube'

require 'lims/core/persistence/store'

module Lims::Core
  module Actions
    describe CreateTube do
      context "with a valid store" do
        # @todo special test session class ?
        before { Persistence::Session.any_instance.stub(:save)   }
        let (:store) { Persistence::Store.new }
        let(:user) { mock(:user) }
        let(:application) { "Test create tube" }

        context "create an empty tube" do

          subject do CreateTube.new(:store => store, :user => user, :application => application)  do |a,s|
          end
          end
          it_behaves_like "an action"
          it "create a tube when called" do
            tube = subject.call()
            tube.should be_a Laboratory::Tube
          end

          it "saves the created tube" do
            Persistence::Session.any_instance.should_receive(:save).with("papoo")
            subject.call
          end
        end
      end
    end
  end
end
