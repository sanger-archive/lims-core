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
        include_context "create object"
        let (:store) { Persistence::Store.new }
        let(:user) { mock(:user) }
        let(:application) { "Test create tube" }

        context "create an empty tube" do

          subject do CreateTube.new(:store => store, :user => user, :application => application)  do |a,s|
          end
          end
          it_behaves_like "an action"
          it "create a tube when called" do
            Persistence::Session.any_instance.should_receive(:save)
            result = subject.call
            result.should be_a(Hash)
            result[:tube].should be_a(Laboratory::Tube)
            result[:uuid].should == uuid
          end
        end

        context "create a tube with samples" do
          let(:sample) { new_sample(1) }
          subject do 
            CreateTube.new(:store => store, :user => user, :application => application, :aliquots => [{:sample => sample }]) do |a,s|
            end
          end
          it_behaves_like "an action"
          it "create a tube when called" do
            Persistence::Session.any_instance.should_receive(:save)
            result = subject.call
            result.should be_a(Hash)
            result[:tube].should be_a(Laboratory::Tube)
            result[:uuid].should == uuid
            result[:tube].first.sample.should == sample
          end
        end
      end
    end
  end
end
