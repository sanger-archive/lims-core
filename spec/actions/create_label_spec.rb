# Spec requirements
require 'actions/action_examples'
require 'actions/spec_helper'
require 'persistence/sequel/store_shared'

# Model requirements
require 'lims/core/actions/create_labellable'
require 'lims/core/actions/create_label'
require 'lims/core/laboratory/sanger_barcode'

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

      let!(:labellable) { store.with_session do |session|
          session << labellable=Laboratory::Labellable.new({:name => location, :type => "resource"})
          labellable
        end
      }
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

#    shared_context "for Labellable without label(s)" do
#      subject do
#        CreateLabel.new(:store => store, :user => user, :application => application)  do |action, session|
#          action.ostruct_update(required_labellable_parameters)
#        end
#      end
#
#      let(:label_checker) {
#        lambda { |labellable|
#          labellable.positions.should be_empty
#          labellable.positions.should be_a(Array)
#          labellable.labels.should be_empty
#          labellable.labels.should be_a(Array)
#        }
#      }
#    end

    shared_context "for Laballable with label content(s)" do
#      let(:labels_parameters) { { :labels => { position1 =>
#        Lims::Core::Laboratory::SangerBarcode.new({:value => label_type_1 })
#      } } }
      subject do
        CreateLabel.new(:store => store, :user => user, :application => application)  do |action, session|
          action.ostruct_update(required_labellable_parameters)
#          action.label = labels_parameters
        end
      end

      let(:label_checker) {
        lambda { |labellable|
          labellable.positions.should_not be_empty
          labellable.positions.should be_a(Array)
          labellable.labels.should_not be_empty
          labellable.labels.should be_a(Array)

          labellable.positions[0] == label_position
        }
      }
    end

    shared_examples_for "creating a Labellable with label(s)" do
      include_context "create object"
      it_behaves_like "an action"
      it "creates a labellable when called" do

        result = subject.call()
        result.should be_a(Hash)

        labellable = result[:labellable]
        labellable.name.should == location

        labellable_checker[labellable]
        label_checker[labellable]
      end
    end

    describe CreateLabel do
      context "with a valid store" do
        include_context "sequel store"
        include_context("setup required attributes for label")

#        context "to be valid Laballable" do
#          subject { Lims::Core::Laboratory::Labellable }
#          specify { subject.new(required_labellable_parameters).should be_valid }
#        end

        context "valid calling context" do
          include_context("for application", "Test create laballable with label content")

          context do
            include_context("for Laballable with label content(s)")
            include_context("for common labellable checker")
            it_behaves_like("creating a Labellable with label(s)")
          end
        end
      end
    end
  end
end
