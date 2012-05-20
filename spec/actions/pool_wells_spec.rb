# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

require 'persistence/sequel/spec_helper'
require 'laboratory/plate_shared'
require 'persistence/sequel/store_shared'

#Model requirements
require 'lims/core/actions/pool_wells'

require 'lims/core/persistence/sequel/store'

require 'logger'
DB = Sequel.sqlite '', :logger => Logger.new($stdout)
PS=Lims::Core::Persistence::Sequel

module Lims::Core
  module Actions
    describe PoolWells do
      include_context "plate factory"
      let(:row_number) {8}
      let(:column_number) {12}
      context "with a sequel store" do
        include_context "prepare tables"
        let(:db) { ::Sequel.sqlite('') }
        let(:store) { PS::Store.new(db) }
        before (:each) { prepare_table(db) }

        context "and everything already in the database" do
          let(:plate) { new_plate_with_samples(1) }
          let(:plate_id) { save(plate) }

          let(:user) { mock(:user) }
          let(:application) { "Test assign pool to wells" }
          subject { described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.source = s.plate[plate_id]
            a.target = new_empty_plate
            a.pools = pools

            a.pool_to_well_map = pool_to_well_map

          end
          }

          context "pool by columns" do
            let(:pools) { 1.upto(column_number).mash {|c| [c, 1.upto(row_number).map { |r| plate.indexes_to_well_name(r-1, c-1) }] } }
            let(:pool_to_well_map) { 1.upto(column_number).mash { |c| [c,plate.indexes_to_well_name(0,c-1)] } }

            it "pools the well as expected" do
              new_plate_id = subject.call {  |a,s| s.id_for(a.target) }
              store.with_session do |session|
                plate = session.plate[new_plate_id]

                plate.each_with_index do  |well, name|
                  case name
                  when /A(\d+)/ 
                    column = $1
                    well.size.should == row_number
                    well.each do |aliquot|
                      aliquot.sample.should =~ /Sample [A-H]#{column}\/\d/
                    end
                  else 
                    well.should be_empty
                  end
                end
              end
            end
          end
          context "pool by rows" do
            let(:pools) { 1.upto(row_number).mash {|r| [r, 1.upto(column_number).map { |c| plate.indexes_to_well_name(r-1,c-1) }] } }
            let(:pool_to_well_map) { 1.upto(row_number).mash { |r| [r, plate.indexes_to_well_name(r-1,0)] } }

            it "pools the well as expected" do
              new_plate_id = subject.call {  |a,s| s.id_for(a.target) }
              store.with_session do |session|
                plate = session.plate[new_plate_id]

                plate.each_with_index do  |well, name|
                  case name
                  when /([A-H])1\z/ 
                    row = $1
                    well.size.should == column_number
                    well.each do |aliquot|
                      aliquot.sample.should =~ /Sample #{row}\d+\/\d/
                    end
                  else 
                    well.should be_empty
                  end
                end
              end
            end
          end
        end

        context "with an empty database" do
          let(:row_number) {3}
          let(:column_number) {5}
          let(:user) { mock(:user) }
          let(:application) { "Test assign pool to well" }

          subject { described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.source = new_plate_with_samples
            a.target = new_empty_plate
            a.pools = {}

            a.pool_to_well_map = {}
          end
          }

          it "should save everything" do
            plate_id = subject.call { |a, s| s.id_for(a.source) }
            store.with_session do |session|
              plate = session.plate[plate_id]
              plate[:C1].should_not be_empty
            end
          end
        end
      end
    end
  end
end
