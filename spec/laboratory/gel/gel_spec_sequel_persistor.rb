# Spec requirements
require 'persistence/sequel/spec_helper'

require 'laboratory/plate_and_gel_shared'
require 'persistence/resource_shared'
require 'persistence/sequel/store_shared'
require 'persistence/sequel/label_filter_shared'
require 'persistence/sequel/batch_filter_shared'
require 'persistence/sequel/order_lookup_filter_shared'
require 'persistence/sequel/multi_criteria_filter_shared'

# Model requirement
require 'lims-core/laboratory/gel'

module Lims::Core
  describe "Persistence#Sequel#Gel", :gel => true, :laboratory => true, :sequel => true do
    include_context "sequel store"
    include_context "plate or gel factory"

    def last_gel_id(session)
      session.gel.dataset.order_by(:id).last[:id]
    end

    context "8*12 Gel" do
      # Set default dimension to create a plate
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12 }
      let(:expected_plate_size) { number_of_rows*number_of_columns }

      context do
        subject { new_gel_with_samples(3) }
        it_behaves_like "storable resource", :gel, {:gels => 1, :windows =>  8*12*3 }
      end

      context "already created gel" do
        let(:aliquot) { new_aliquot }
        before (:each) do
          store.with_session { |session| session << new_empty_gel.tap {|_| _[0] << aliquot} }
        end
        let(:gel_id) { store.with_session { |session| @gel_id = last_gel_id(session) } }

        context "when modified within a session" do
          before do
            store.with_session do |s|
              gel = s.gel[gel_id]
              gel[0].clear
              gel[1]<< aliquot
            end
          end
          it "should be saved" do
            store.with_session do |session|
              f = session.gel[gel_id]
              f[7].should be_empty
              f[1].should == [aliquot]
              f[0].should be_empty
            end
          end
        end
        context "when modified outside a session" do
          before do
            gel = store.with_session do |s|
              s.gel[gel_id]
            end
            gel[0].clear
            gel[1]<< aliquot
          end
          it "should not be saved" do
            store.with_session do |session|
              f = session.gel[gel_id]
              f[7].should be_empty
              f[1].should be_empty
              f[0].should == [aliquot]
            end
          end
        end
        context "should be deletable" do
          before {
            # add some aliquot to the windows
            store.with_session do |session|
            gel = session.gel[gel_id]
            1.upto(10) { |i|  3.times { |j| gel[i] <<  new_aliquot(i,j) } }
            end
          }

          def delete_gel
            store.with_session do |session|
              gel = session.gel[gel_id]
              session.delete(gel)
            end
          end

          it "deletes the gel row" do
            expect { delete_gel }.to change { db[:gels].count}.by(-1)
          end

          it "deletes the window rows" do
            expect { delete_gel }.to change { db[:windows].count}.by(-31)
          end
        end

        context "#lookup" do
          let(:model) { Laboratory::Gel }
          # These uuids match the uuids defined for the order items 
          # in order_lookup_filter_shared.
          let!(:uuids) {
            ['11111111-2222-0000-0000-000000000000', 
             '22222222-1111-0000-0000-000000000000',
             '00000000-3333-0000-0000-000000000000'].tap do |uuids|
               uuids.each_with_index do |uuid, index|
                 store.with_session do |session|
                   gel =  new_empty_gel.tap { |gel| gel[index] << new_aliquot}
                   session << gel
                   ur = session.new_uuid_resource_for(gel)
                   ur.send(:uuid=, uuid)
                 end
               end
             end
          }

          context "by label" do
            let!(:uuid) {
              store.with_session do |session|
                gel = session.gel[gel_id]
                session.uuid_for!(gel)
              end
            }
            it_behaves_like "labels filtrable"
          end

          context "by order" do
            it_behaves_like "orders filtrable"
          end

          context "by batch" do
            it_behaves_like "batch filtrable"
          end
        end
      end

      context do
        let(:constructor) { lambda { |*_| new_empty_gel } }
        it_behaves_like "paginable resource", :gel
        it_behaves_like "filtrable", :gel
      end
    end
  end
end
