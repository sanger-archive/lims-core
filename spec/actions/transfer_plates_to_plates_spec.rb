# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/store_shared'
require 'laboratory/plate_and_gel_shared'
require 'laboratory/tube_rack_shared'

# Model requirements
require 'lims/core/actions/transfer_plates_to_plates'

# check whether the aliquot quantity is zero in the element (well or window)
def zero_aliquot_quantity?(w)
  valid = true
  w.each do |aliquot|
    if aliquot.quantity != 0
      valid = false
      break;
    end
  end
  valid
end

shared_examples_for "transfer from many plates to many gels" do
  it "transfers the contents of plate-like(s) to plate-like(s)" do
    subject.call
    store.with_session do |session|
      plate1, plate2 = [plate1_id, plate2_id].map { |id| session.plate[id] }
      gel1, gel2 = [gel1_id, gel2_id].map { |id| session.gel[id] }

      # I think, it should be as simple as this:
      # plate1["A1"].should be_nil
      # but the aliquot implementation is just setting the quantity to 0
      zero_aliquot_quantity?(plate1["A1"]).should == true
      zero_aliquot_quantity?(plate1["C3"]).should == true

      gel1["B2"].should_not be_nil
      gel1["E8"].should_not be_nil
      gel1.each do |window|
        window.each do |aliquot|
          aliquot.type.should == type1
        end
      end

      zero_aliquot_quantity?(plate2["A1"]).should == true
      zero_aliquot_quantity?(plate2["C3"]).should == true

      gel2["B2"].should_not be_nil
      gel2["E8"].should_not be_nil
      gel2.each do |window|
        window.each do |aliquot|
          aliquot.type.should == type2
        end
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

      # I think, it should be as simple as this:
      # rack1["A1"].should be_nil
      # but the aliquot implementation is just setting the quantity to 0
      zero_aliquot_quantity?(rack1["A1"]).should == true
      zero_aliquot_quantity?(rack1["C3"]).should == true

      plate1["B2"].should_not be_nil
      plate1["E8"].should_not be_nil
      plate1.each do |window|
        window.each do |aliquot|
          aliquot.type.should == type1
        end
      end

      zero_aliquot_quantity?(rack2["A1"]).should == true
      zero_aliquot_quantity?(rack2["C3"]).should == true

      plate2["B2"].should_not be_nil
      plate2["E8"].should_not be_nil
      plate2.each do |window|
        window.each do |aliquot|
          aliquot.type.should == type2
        end
      end
    end
  end
end

module Lims::Core
  module Actions
    describe TransferPlatesToPlates do
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
            let(:type1) { "NA" }
            let(:type2) { "DNA" }
            context "transfer from 2 plates to 2 gels" do
              let(:plate1_id) { save(new_plate_with_samples(5, 100)) }
              let(:plate2_id) { save(new_plate_with_samples(5, 100)) }
              let(:gel1_id) { save(new_empty_gel) }
              let(:gel2_id) { save(new_empty_gel) }

              subject { described_class.new(:store => store, 
                                            :user => user, 
                                            :application => application) do |action, session|
                plate1, plate2 = [plate1_id, plate2_id].map { |id| session.plate[id] }
                gel1, gel2 = [gel1_id, gel2_id].map { |id| session.gel[id] }

                action.transfers = [ { "source" => plate1,
                                       "target" => gel1,
                                       "transfer_map" => { "A1" => "B2", "C3" => "E8" },
                                       "aliquot_type" => type1},
                                     { "source" => plate2,
                                       "target" => gel2,
                                       "transfer_map" => { "A1" => "B2", "C3" => "E8" },
                                       "aliquot_type" => type2}
                ]
              end
              }

              it_behaves_like "transfer from many plates to many gels"
            end

            context "transfer from 2 racks to 2 plates" do
              let(:rack1_id) { save(new_tube_rack_with_samples(5, 100)) }
              let(:rack2_id) { save(new_tube_rack_with_samples(5, 100)) }
              let(:plate1_id) { save(new_empty_plate) }
              let(:plate2_id) { save(new_empty_plate) }
        
              subject { described_class.new(:store => store, 
                                            :user => user, 
                                            :application => application) do |action, session|
                rack1, rack2 = [rack1_id, rack2_id].map { |id| session.tube_rack[id] }
                plate1, plate2 = [plate1_id, plate2_id].map { |id| session.plate[id] }
        
                action.transfers = [ { "source" => rack1,
                                       "target" => plate1,
                                       "transfer_map" => { "A1" => "B2", "C3" => "E8" },
                                       "aliquot_type" => type1},
                                     { "source" => rack2,
                                       "target" => plate2,
                                       "transfer_map" => { "A1" => "B2", "C3" => "E8" },
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
