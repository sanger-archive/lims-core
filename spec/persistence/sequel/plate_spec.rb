# Spec requirements
require 'persistence/sequel/spec_helper'

require 'laboratory/plate_shared'
require 'persistence/sequel/store_shared'
require 'persistence/sequel/page_shared'

# Model requirements
require 'lims/core/laboratory/plate'

require 'logger'
module Lims::Core

  describe "Sequel#Plate " do
    include_context "sequel store"
    include_context "plate factory"

    def last_plate_id(session)
      session.plate.dataset.order_by(:id).last[:id]
    end

    context "8*12 Plate" do
      # Set default dimension to create a plate
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12 }
      let(:expected_plate_size) { number_of_rows*number_of_columns }

      context "created and added to session" do
        it "modifies the plates table" do
          expect do
            store.with_session { |s| s << new_plate_with_samples }
          end.to change { db[:plates].count }.by(1)
        end

        it "modifies the wells table" do
          expect do
            store.with_session { |session| session << new_plate_with_samples(3) }
          end.to change { db[:wells].count }.by(expected_plate_size*3)
        end

        it "should be reloadable" do
          plate = store.with_session do |session|
            new_plate_with_samples(3).tap do |f|
              session << f
            end
          end
          store.with_session do |session|
            new_plate  = session.plate[last_plate_id(session)]
            plate.should eq(session.plate[last_plate_id(session)])
          end
        end
      end

      context "created but not added to a session" do
        it "should not be saved" do
          expect do 
            store.with_session { |_| new_plate_with_samples(3) }
          end.to change{ db[:plates].count }.by(0)
        end 
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
            1.upto(10) { |i|  3.times { plate[i] <<  new_aliquot } }
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
        it_behaves_like "paginable", :plate
      end
    end
  end
end
