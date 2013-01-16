# Spec requirements
require 'actions/action_examples'
require 'actions/spec_helper'
require 'persistence/sequel/store_shared'

# Model requirements
require 'lims/core/actions/create_labellable'
require 'lims/core/actions/create_label'

module Lims::Core
  module Actions

    shared_context "setup required attributes for label" do
      let(:location) { "00000000-1111-2222-333333333333" } # uuid of an asset (i.e. plate)
      let(:label_position) { "front barcode" }
      let(:label_type) { "sanger-barcode" }
      let(:label_value) { "1234-ABC" }
      let(:required_labellable_parameters) { { :location => location,
                                               :type => label_type,
                                               :value => label_value,
                                               :position => label_position}
      }

      let!(:labellable) { 
        store.with_session do |session|
          session << labellable=Laboratory::Labellable.new({:name => location, :type => "resource"})
          labellable
        end
      }
    end

    shared_context "for Laballable with label content(s)" do
      let(:created_label) {
        CreateLabel.new(:store => store, :user => user, :application => application)  do |action, session|
          action.ostruct_update(required_labellable_parameters)
        end
      }
    end

    shared_examples_for "a label" do
      subject { result }
      it { should be_a(Lims::Core::Laboratory::Labellable) }

      subject { labellable_result }
      its(:positions) { should_not be_empty }
      its(:positions) { should be_a(Array) }
      its(:labels) { should_not be_empty }
      its(:labels) { should be_a(Array) }

      its(:positions) { subject[0].should == label_position }
      its(:labels) { subject[0].type.should == label_type }
      its(:labels) { subject[0].value.should == label_value }
    end

    shared_examples_for "a labellable" do
      subject { labellable_result }
      its(:name) { should == location }
      its(:name) { should_not be_empty }
      its(:name) { should be_a(String) }
      its(:type) { should_not be_empty }
      its(:type) { should be_a(String) }
    end

    shared_examples_for "a labellable action" do
      subject { created_label }
      it_behaves_like "an action"
    end

    shared_context "creating a Labellable with label(s)" do
      let(:result) { created_label.call() }
      let(:labellable_result) { result[:labellable] }
    end

    describe CreateLabel do
      context "with a valid store" do
        include_context "sequel store"
        include_context("setup required attributes for label")

        context "valid calling context" do
          include_context("for application", "Test create laballable with label content")

          context do
            include_context("for Laballable with label content(s)")
            include_context("creating a Labellable with label(s)")

            it_behaves_like "a label"
            it_behaves_like "a labellable"
            it_behaves_like "a labellable action"
          end
        end
      end
    end
  end
end
