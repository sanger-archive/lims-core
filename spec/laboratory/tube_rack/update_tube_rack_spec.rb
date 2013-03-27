# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'
require 'laboratory/tube_rack_shared'

# Model requirements
require 'lims-core/laboratory/tube_rack/update_tube_rack'
require 'lims-core/laboratory/tube_rack'

module Lims::Core
  module Laboratory
    describe TubeRack::UpdateTubeRack, :tube_rack => true, :laboratory => true, :persistence => true do
      include_context "for application", "test update tube rack"
      include_context "tube_rack factory"
      include_context "create object"

      let!(:store) { Persistence::Store.new }
      let(:tube_rack) { new_tube_rack_with_samples }
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12 }
      let(:aliquot_type) { "DNA" }
      let(:aliquot_quantity) { 5 }
      let(:action) {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.tube_rack = tube_rack 
          a.aliquot_type = aliquot_type
          a.aliquot_quantity = aliquot_quantity
        end
      }
      let(:result) { action.call }
      let(:updated_tube_rack) { result[:tube_rack] }
      subject { action }

      it_behaves_like "an action"

      it "updates the tube rack" do
        result.should be_a Hash
        updated_tube_rack.should be_a Laboratory::TubeRack
      end

      it "changes aliquots type in each tube" do
        updated_tube_rack.each do |tube|
          tube.each do |aliquot|
            aliquot.type.should == aliquot_type
          end
        end
      end

      it "changes aliquots quantity in each tube" do
        updated_tube_rack.each do |tube|
          tube.each do |aliquot|
            aliquot.quantity.should == aliquot_quantity
          end
        end
      end
    end
  end
end
