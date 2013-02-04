# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

require 'persistence/sequel/spec_helper'
require 'laboratory/plate_and_gel_shared'
require 'laboratory/tube_shared'
require 'persistence/sequel/store_shared'

#Model requirements
require 'lims/core/actions/transfer_wells_to_tubes'

require 'lims/core/persistence/sequel/store'

require 'logger'
PS=Lims::Core::Persistence::Sequel

module Lims::Core
  module Actions
    describe TransferWellsToTubes do
      include_context "plate or gel factory"
      include_context "tube factory"
      let(:number_of_rows) {8}
      let(:number_of_columns) {12}
      context "with a sequel store" do
        include_context "prepare tables"
        let(:db) { ::Sequel.sqlite('') }
        let(:store) { PS::Store.new(db) }
        before (:each) { prepare_table(db) }

        context "and everything already in the database" do
          let(:plate_id) { save(new_plate_or_gel_with_samples(Laboratory::Plate, 1)) }
          let(:tube1_id) { save(new_empty_tube) }
          let(:tube2_id) { save(new_empty_tube) }

          let(:user) { mock(:user) }
          let(:application) { "test transfer wells to tubes" }

          context "with valid parameters" do
            subject { described_class.new(:store => store, :user => user, :application => application) do |a,s|
              a.plate = s.plate[plate_id]
              tube1, tube2 = [tube1_id, tube2_id].map { |id| s.tube[id] }
              a.well_to_tube_map =  {"A1" => tube1, "C3" => tube2}
            end
            }

            it "transfers the well as expected" do
              subject.call
              store.with_session do |session|
                plate = session.plate[plate_id]
                tube1, tube2 = [tube1_id, tube2_id].map { |id| session.tube[id] }
                tube1.should == plate["A1"]
                tube2.should == plate["C3"] 
              end
            end
          end

          context "with invalid parameters like" do
            context "two wells going in the same tube" do
              subject { described_class.new(:store => store, :user => user, :application => application) do |a,s|
                a.plate = s.plate[plate_id]
                tube1, tube2 = [tube1_id, tube2_id].map { |id| s.tube[id] }
                a.well_to_tube_map =  {"A1" => tube1, "C3" => tube1}
              end
              }

              pending "not implemented" do
              it "should raise an exception" do
                expect { subject.call}.to raise_error(Action::InvalidParameters)
              end
            end
            end
          end
        end

        context "with an empty database" do
          let(:number_of_rows) {3}
          let(:number_of_columns) {5}
          let(:user) { mock(:user) }
          let(:application) { "Test assign tag to well" }
          let(:tube) {  new_empty_tube }
          let(:plate) { new_plate_or_gel_with_samples(Laboratory::Plate) }
          subject { described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.plate = plate
            a.well_to_tube_map = {"C3" => tube } 
          end
          }

          it "should save all the tubes" do
            plate_id, tube_id = subject.call { |a, s| [s.id_for(plate), s.id_for(tube)] }
            store.with_session do |session|
              tube.should == plate["C3"]
            end
          end
        end
      end
    end
  end
end
