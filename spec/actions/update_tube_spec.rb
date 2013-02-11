# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'
require 'laboratory/tube_shared'

# Model requirements
require 'lims/core/actions/update_tube'
require 'lims/core/laboratory/tube'

module Lims::Core
  module Actions
    describe UpdateTube do
      context "valid calling context" do
        include_context "for application", "test update tube" 
        include_context "tube factory"
        include_context "create object"

        let!(:store) { Persistence::Store.new() }
        let(:aliquot_type) { "DNA" }
        let(:aliquot_quantity) { 5 }
        let(:action) { 
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.tube = new_tube_with_samples
            a.aliquot_type = aliquot_type
            a.aliquot_quantity = aliquot_quantity
          end
        }
        let(:result) { action.call }
        let(:updated_tube) { result[:tube] }
        subject { action }

        it_behaves_like "an action"

        it "updates the tube" do
          result.should be_a Hash
          updated_tube.should be_a Laboratory::Tube
        end

        it "changes the aliquots type" do
          updated_tube.each do |aliquot|
            aliquot.type.should == aliquot_type
          end
        end

        it "changes the aliquots quantity" do
          updated_tube.each do |aliquot|
            aliquot.quantity.should == aliquot_quantity
          end
        end
      end
    end
  end
end
