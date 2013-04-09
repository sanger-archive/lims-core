# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'
require 'laboratory/plate_and_gel_shared'

# Model requirements
require 'lims-core/laboratory/plate/update_plate'
require 'lims-core/laboratory/plate'

module Lims::Core
  module Laboratory
    describe Plate::UpdatePlate, :plate => true, :laboratory => true, :persistence => true do
      include_context "for application", "test update tube rack"
      include_context "plate or gel factory"
      include_context "create object"

      let!(:store) { Persistence::Store.new }
      let(:plate) { new_plate_with_samples }
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12 }
      let(:plate_type) { "new plate type" }
      let(:aliquot_type) { "DNA" }
      let(:aliquot_quantity) { 5 }
      let(:action) {
        described_class.new(:store => store, :user => user, :application => application) do |a,s|
          a.plate = plate 
          a.aliquot_type = aliquot_type
          a.aliquot_quantity = aliquot_quantity
          a.type = plate_type
        end
      }
      let(:result) { action.call }
      let(:updated_plate) { result[:plate] }
      subject { action }

      it_behaves_like "an action"

      it "updates the plate" do
        result.should be_a Hash
        updated_plate.should be_a Laboratory::Plate
      end

      it "changes the plate type" do
        updated_plate.type.should == plate_type        
      end

      it "changes aliquots type in each well" do
        updated_plate.each do |well|
          well.each do |aliquot|
            aliquot.type.should == aliquot_type
          end
        end
      end

      it "changes aliquots quantity in each well" do
        updated_plate.each do |well|
          well.each do |aliquot|
            aliquot.quantity.should == aliquot_quantity
          end
        end
      end
    end
  end
end
