# Spec requirements
require 'persistence/sequel/spec_helper'

require 'laboratory/plate_shared'
require 'persistence/resource_shared'
require 'persistence/sequel/store_shared'
require 'persistence/sequel/page_shared'
require 'persistence/sequel/multi_criteria_filter_shared'


# Model requirements
require 'lims/core/laboratory/plate'

module Lims::Core

  describe "Sequel#Plate " do
    include_context "sequel store"
    include_context "plate factory"

    include

    def last_plate_id(session)
      session.plate.dataset.order_by(:id).last[:id]
    end

    context "8*12 Plate" do
      # Set default dimension to create a plate
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12 }
      let(:expected_plate_size) { number_of_rows*number_of_columns }

      context do
        subject { new_plate_with_samples(3) }
        it_behaves_like "storable resource", :plate, {:plates => 1, :wells =>  8*12*3 }
      end

      context "already created plate" do
        let(:aliquot) { new_aliquot }
        before (:each) do
          store.with_session { |session| session << new_empty_plate().tap {|_| _[0] << aliquot} }
        end
        let(:plate_id) { store.with_session { |session| @plate_id = last_plate_id(session) } }

        context "when modified within a session" do
          before do
            store.with_session do |s|
              plate = s.plate[plate_id]
              plate[0].clear
              plate[1]<< aliquot
            end
          end
          it "should be saved" do
            store.with_session do |session|
              f = session.plate[plate_id]
              f[7].should be_empty
              f[1].should == [aliquot]
              f[0].should be_empty
            end
          end
        end
        context "when modified outside a session" do
          before do
            plate = store.with_session do |s|
              s.plate[plate_id]
            end
            plate[0].clear
            plate[1]<< aliquot
          end
          it "should not be saved" do
            store.with_session do |session|
              f = session.plate[plate_id]
              f[7].should be_empty
              f[1].should be_empty
              f[0].should == [aliquot]
            end
          end
        end
        context "should be deletable" do
          before {
            # add some aliquot to the wells
            store.with_session do |session|
            plate = session.plate[plate_id]
            1.upto(10) { |i|  3.times { |j| plate[i] <<  new_aliquot(i,j) } }
            end
          }

          def delete_plate
            store.with_session do |session|
              plate = session.plate[plate_id]
              session.delete(plate)
            end
          end

          it "deletes the plate row" do
            expect { delete_plate }.to change { db[:plates].count}.by(-1)
          end

          it "deletes the well rows" do
            expect { delete_plate }.to change { db[:wells].count}.by(-31)
          end
        end
      end

      context do
        let(:constructor) { lambda { |*_| new_empty_plate } }
        it_behaves_like "paginable resource", :plate
        it_behaves_like "filtrable", :plate
      end
    end
  end
end
