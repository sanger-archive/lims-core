# Spec requirements
require 'actions/action_examples'
require 'actions/spec_helper'

# Model requirements
require 'lims/core/actions/create_labellable'
require 'lims/core/actions/create_label'
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  module Actions
    shared_context "setup required attributes" do |name, labellable_type|
      let(:name) { name }
      let(:labellable_type) { labellable_type }
      let(:required_labellable_parameters) { { :name => name, :type => labellable_type } }
    end

    shared_context "for common labellable checker" do
      let(:labellable_checker) {
        lambda { |labellable|
          labellable.name.should_not be_empty
          labellable.name.should be_a(String)
          labellable.type.should_not be_empty
          labellable.type.should be_a(String)
        }
      }
    end

    shared_context "for Labellable without label(s)" do
      subject do
        CreateLabellable.new(:store => store, :user => user, :application => application)  do |action, session|
          action.ostruct_update(required_labellable_parameters)
        end
      end

      let(:label_checker) {
        lambda { |labellable|
          labellable.positions.should be_empty
          labellable.positions.should be_a(Array)
          labellable.labels.should be_empty
          labellable.labels.should be_a(Array)
        }
      }
    end

    shared_context "for Laballable with label content(s)" do
      let(:position_1) { "front barcode" }
      let(:value_1) { "1234-ABC" }
      let(:label_type_1) { "sanger barcode" }
      let(:labels_parameters) { { :labels => { position1 =>
        Lims::Core::Laboratory::SangerBarcode.new({:value => label_type_1 })
      } } }
#      let(:label) { { "front barcode" => Lims::Core::Laboratory::SangerBarcode.new({:value =>"12345ABC" }) } }
      subject do
        CreateLabel.new(:store => store, :user => user, :application => application)  do |action, session|
          action.ostruct_update(required_labellable_parameters)
#          action.label = labels_parameters
          action.label_type = label_type_1
          action.value = value_1
          action.position = position_1
        end
      end

      let(:label_checker) {
        lambda { |labellable|
          labellable.positions.should_not be_empty
          labellable.positions.should be_a(Array)
          labellable.labels.should_not be_empty
          labellable.labels.should be_a(Array)

          labellable.positions[0] == position_1

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
        labellable.type.should == labellable_type
        labellable.name.should == name

        labellable_checker[labellable]
        label_checker[labellable]

        result[:uuid].should == uuid
      end
    end

    describe CreateLabellable do
      context "with a valid store" do
        let!(:store) { Persistence::Store.new }
        include_context("setup required attributes", "my test plate", "plate")

        context "to be valid Laballable" do
          subject { Lims::Core::Laboratory::Labellable }
          specify { subject.new(required_labellable_parameters).should be_valid }
        end

        context "valid calling context" do
          include_context("for application", "Test create laballable")

          context do
            include_context("for Labellable without label(s)")
            include_context("for common labellable checker")
            it_behaves_like("creating a Labellable")
          end

          context do
            subject { Lims::Core::Actions::CreateLabel }
            include_context("for Laballable with label content(s)")
            include_context("for common labellable checker")
            it_behaves_like("creating a Labellable")
          end
        end
      end
    end
  end
end
