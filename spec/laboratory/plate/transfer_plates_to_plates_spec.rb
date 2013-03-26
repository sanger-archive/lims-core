# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/store_shared'
require 'laboratory/plate_and_gel_shared'
require 'laboratory/tube_rack_shared'

# Model requirements
require 'lims-core/laboratory/plate/transfer_plates_to_plates'

shared_examples_for "transfer from many plates to many gels" do
  it "transfers the contents of plate-like(s) to plate-like(s)" do
    subject.call
    store.with_session do |session|
      plate1, plate2 = [plate1_id, plate2_id].map { |id| session.plate[id] }
      gel1, gel2 = [gel1_id, gel2_id].map { |id| session.gel[id] }

      plate1["A1"].quantity.should == final_quantity_plate1_A1
      plate1["C3"].quantity.should == final_quantity_plate1_C3

      gel1["B2"].should_not be_nil
      gel1["E8"].should_not be_nil

      gel1["B2"].each do |aliquot|
        aliquot.type.should == type1
      end

      gel1["E8"].each do |aliquot|
        aliquot.type.should == type1
      end

      plate2["A1"].quantity.should == final_quantity_plate2_A1
      plate2["C3"].quantity.should == final_quantity_plate2_C3

      gel2["B2"].should_not be_nil
      gel2["E8"].should_not be_nil

      gel2["B2"].each do |aliquot|
        aliquot.type.should == type2
      end

      gel2["E8"].each do |aliquot|
        aliquot.type.should == type2
      end
    end
  end
end

shared_examples_for "transfer from many racks to many plates" do
  it "transfers the contents of plate-like(s) to plate-like(s)" do
    subject.call
    store.with_session do |session|
      rack1, rack2 = [rack1_id, rack2_id].map { |id| session.tube_rack[id] }
      plate1, plate2 = [plate1_id, plate2_id].map { |id| session.plate[id] }

      rack1["A1"].quantity.should == final_quantity_rack1_A1
      rack1["C3"].quantity.should == final_quantity_rack1_C3
      plate1["B2"].should_not be_nil
      plate1["E8"].should_not be_nil

      plate1["B2"].each do |aliquot|
        aliquot.type.should == type1
        aliquot.quantity.should == final_quantity_plate1_B2
      end

      plate1["E8"].each do |aliquot|
        aliquot.type.should == type1
        aliquot.quantity.should == final_quantity_plate1_E8
      end

      rack2["A1"].quantity.should == final_quantity_rack2_A1
      rack2["C3"].quantity.should == final_quantity_rack2_C3
      plate2["B2"].should_not be_nil
      plate2["E8"].should_not be_nil

      plate2["B2"].each do |aliquot|
        aliquot.type.should == type2
        aliquot.quantity.should == final_quantity_plate2_B2
      end

      plate2["E8"].each do |aliquot|
        aliquot.type.should == type2
        aliquot.quantity.should == final_quantity_plate2_E8
      end
    end
  end
end

module Lims::Core
  module Laboratory
    describe Plate::TransferPlatesToPlates do
      include_context "plate or gel factory"
      include_context "tube_rack factory"

      context "with a sequel store" do
        include_context "sequel store"

        context "and everything already in the database" do
          let(:user) { mock(:user) }
          let(:application) { "test transfer plate-like(s) to plate-like(s) with a given transfer map" }
          let(:number_of_rows) { 8 }
          let(:number_of_columns) { 12 }

          context "with valid parameters" do
            let(:type1) { "RNA" }
            let(:type2) { "DNA" }
            context "transfer from 2 plates to 2 gels" do
              let(:quantity1) { 100 }
              let(:quantity2) { 100 }
              let(:final_quantity_plate1_A1) { 40 }
              let(:final_quantity_plate1_C3) { 40 }
              let(:final_quantity_plate2_A1) { 70 }
              let(:final_quantity_plate2_C3) { 70 }
              let(:final_quantity_gel1_B2) { 60 }
              let(:final_quantity_gel1_E8) { 60 }
              let(:final_quantity_gel2_B2) { 30 }
              let(:final_quantity_gel2_E8) { 30 }
              let(:plate1_id) { save(new_plate_with_samples(5, quantity1)) }
              let(:plate2_id) { save(new_plate_with_samples(5, quantity2)) }
              let(:gel1_id) { save(new_empty_gel) }
              let(:gel2_id) { save(new_empty_gel) }

              subject { described_class.new(:store => store, 
                                            :user => user, 
                                            :application => application) do |action, session|
                plate1, plate2 = [plate1_id, plate2_id].map { |id| session.plate[id] }
                gel1, gel2 = [gel1_id, gel2_id].map { |id| session.gel[id] }

                action.transfers = [ { "source" => plate1,
                                       "source_location" => "A1",
                                       "target" => gel1,
                                       "target_location" => "B2",
                                       "fraction" => 0.6,
                                       "aliquot_type" => type1},
                                     { "source" => plate1,
                                       "source_location" => "C3",
                                       "target" => gel1,
                                       "target_location" => "E8",
                                       "fraction" => 0.6,
                                       "aliquot_type" => type1},
                                     { "source" => plate2,
                                       "source_location" => "A1",
                                       "target" => gel2,
                                       "target_location" => "B2",
                                       "fraction" => 0.3,
                                       "aliquot_type" => type2},
                                     { "source" => plate2,
                                       "source_location" => "C3",
                                       "target" => gel2,
                                       "target_location" => "E8",
                                       "fraction" => 0.3,
                                       "aliquot_type" => type2},
                ]
              end
              }

              it_behaves_like "transfer from many plates to many gels"
            end

            context "transfer from 2 racks to 2 plates", :focus => true do
              let(:quantity1) { 1000 }
              let(:quantity2) { 1000 }
              let(:final_quantity_rack1_A1) { 940 }
              let(:final_quantity_rack1_C3) { 940 }
              let(:final_quantity_rack2_A1) { 970 }
              let(:final_quantity_rack2_C3) { 970 }
              let(:final_quantity_plate1_B2) { 60 }
              let(:final_quantity_plate1_E8) { 60 }
              let(:final_quantity_plate2_B2) { 30 }
              let(:final_quantity_plate2_E8) { 30 }
              let(:rack1_id) { save(new_tube_rack_with_samples(5, quantity1, 1000)) }
              let(:rack2_id) { save(new_tube_rack_with_samples(5, quantity2, 1000)) }
              let(:plate1_id) { save(new_empty_plate) }
              let(:plate2_id) { save(new_empty_plate) }
        
              subject { described_class.new(:store => store, 
                                            :user => user, 
                                            :application => application) do |action, session|
                rack1, rack2 = [rack1_id, rack2_id].map { |id| session.tube_rack[id] }
                plate1, plate2 = [plate1_id, plate2_id].map { |id| session.plate[id] }

                  action.transfers = [ { "source" => rack1,
                                       "source_location" => "A1",
                                       "target" => plate1,
                                       "target_location" => "B2",
                                       "amount" => 60,
                                       "aliquot_type" => type1},
                                     { "source" => rack1,
                                       "source_location" => "C3",
                                       "target" => plate1,
                                       "target_location" => "E8",
                                       "amount" => 60,
                                       "aliquot_type" => type1},
                                     { "source" => rack2,
                                       "source_location" => "A1",
                                       "target" => plate2,
                                       "target_location" => "B2",
                                       "amount" => 30,
                                       "aliquot_type" => type2},
                                     { "source" => rack2,
                                       "source_location" => "C3",
                                       "target" => plate2,
                                       "target_location" => "E8",
                                       "amount" => 30,
                                       "aliquot_type" => type2}
                ]
              end
              }
        
              it_behaves_like "transfer from many racks to many plates"
            end
          end

        end
      end
    end
  end
end
