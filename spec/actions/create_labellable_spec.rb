# Spec requirements
require 'actions/action_examples'
require 'actions/spec_helper'

# Model requirements
require 'lims/core/actions/create_labellable'
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  module Actions
    shared_context "setup required attributes" do |name, type|
      let(:name) { name }
      let(:type) { type }
      let(:required_parameters) { { :name => name, :type => type } }
    end

    shared_context "for empty Labellable" do
      subject do
        CreateLabellable.new(:store => store, :user => user, :application => application)  do |action, session|
          action.ostruct_update(required_parameters)
        end
      end

      let(:labellable_checker) {
        lambda { |labellable|
          labellable.content.should be_empty
          labellable.content.should be_a(Hash)
        }
      }
    end

    shared_context "for Laballable with barcode content" do
      let(:content) { { "front barcode" => Lims::Core::Laboratory::SangerBarcode.new({:value =>"12345ABC" }) } }
      subject do
        CreateLabellable.new(:store => store, :user => user, :application => application)  do |action, session|
          action.ostruct_update(required_parameters)
          action.ostruct_update( { :content => content } )
        end
      end

      let(:labellable_checker) {
        lambda { |labellable|
          labellable.content.should_not be_empty
          labellable.content.should be_a(Hash)
          labellable.content.should == content
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
          it do
            s = described_class.new(required_parameters)
            described_class.new(required_parameters).valid?.should == true
          end
        end

        context "valid calling context" do
          include_context("for application", "Test create laballable")

          context do
            include_context("for empty Labellable")
            it_behaves_like("creating a Labellable")
          end

          context do
            include_context("for Laballable with barcode content")
            it_behaves_like("creating a Labellable")
          end
        end
      end
    end
  end
end