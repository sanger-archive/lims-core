# Spec requirements
require 'actions/action_examples'
require 'actions/spec_helper'

# Model requirements
require 'lims/core/actions/create_labellable'

module Lims::Core
  module Actions
    shared_context "setup required attributes" do |name, type|
      let(:name) { name }
      let(:type) { type }
      let(:required_parameters) { { :name => name, :type => type } }
    end

    shared_context "for Labellable (without labels)" do
      subject do
        CreateLabellable.new(:store => store, :user => user, :application => application)  do |action, session|
          action.ostruct_update(required_parameters)
        end
      end

      let(:labellable_checker) {
        lambda { |labellable|
          labellable.name.should_not be_empty
          labellable.name.should be_a(String)
          labellable.type.should_not be_empty
          labellable.type.should be_a(String)
        }
      }
    end

    shared_examples_for "creating a Labellable" do
      include_context "create object"
      it_behaves_like "an action"
      it "creates a labellable when called" do
        result = subject.call()
        result.should be_a(Hash)

        labellable = result[:labellable]
        labellable.type.should == type
        labellable.name.should == name

        labellable_checker[labellable]

        result[:uuid].should == uuid
      end
    end

    describe CreateLabellable do
      context "with a valid store" do
        let!(:store) { Persistence::Store.new }
        include_context("setup required attributes", "my test plate", "plate")

        context "to be valid Laballable" do
          subject { Lims::Core::Laboratory::Labellable }
          specify { subject.new(required_parameters).should be_valid }
        end

        context "valid calling context" do
          include_context("for application", "Test create laballable")

          context do
            include_context("for Labellable (without labels)")
            it_behaves_like("creating a Labellable")
          end

        end
      end
    end
  end
end
