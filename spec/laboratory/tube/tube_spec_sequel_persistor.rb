# Spec requirements
require 'persistence/sequel/spec_helper'

require 'persistence/sequel/store_shared'
require 'laboratory/tube_shared'
require 'persistence/sequel/label_filter_shared'
require 'persistence/sequel/order_lookup_filter_shared'
require 'persistence/sequel/batch_filter_shared'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/laboratory/tube'

module Lims::Core
  describe Laboratory::Tube, :tube => true, :laboratory => true, :persistence => true, :sequel => true do
    include_context "prepare tables"
    include_context "tube factory"
    let(:db) { ::Sequel.sqlite('') }
    let(:store) { Persistence::Sequel::Store.new(db) }
    before (:each) { prepare_table(db) }

    context "created and added to session" do
      it "modifies the tubes table" do
        expect do
          store.with_session { |s| s << subject }
        end.to change { db[:tubes].count }.by(1)
      end

      it "should be reloadable" do
        tube_id = save(subject)
        store.with_session do |session|
          tube = session.tube[tube_id]
          tube.should eq(session.tube[tube_id])
        end
      end

      context "created but not added to a session" do
        it "should not be saved" do
          expect do 
            store.with_session { |_| subject }
          end.to change{ db[:tubes].count }.by(0)
        end 
      end

      context "already created tube" do
        let(:aliquot) { new_aliquot }
        let!(:tube_id) { save(subject) }

        context "when modified within a session" do
          before do
            store.with_session do |s|
              tube = s.tube[tube_id]
              tube << aliquot
            end
          end
          it "should be saved" do
            store.with_session do |session|
              tube = session.tube[tube_id]
              tube.should == [aliquot]
            end
          end
        end
        context "when modified outside a session" do
          before do
            tube = store.with_session do |s|
              s.tube[tube_id]
            end
            tube << aliquot
          end
          it "should not be saved" do
            store.with_session do |session|
              tube = session.tube[tube_id]
              tube.should be_empty
            end
          end
        end

        context "with a tube type" do
          let(:type) { "Eppendorf" }
          subject { Laboratory::Tube.new(:type => type) } 

          it "can be saved and reloaded" do
            tube_id = save(subject)
            
            store.with_session do |session|
              tube = session.tube[tube_id]
              tube.type.should == type
            end
          end
        end

        context "with a tube max volume" do
          let(:max_volume) { 2 }
          subject { Laboratory::Tube.new(:max_volume => max_volume) } 

          it "can be saved and reloaded" do
            tube_id = save(subject)
            
            store.with_session do |session|
              tube = session.tube[tube_id]
              tube.max_volume.should == max_volume
            end
          end
        end

        context "#lookup" do
          let(:model) { Laboratory::Tube }
          # These uuids match the uuids defined for the order items 
          # in order_lookup_filter_shared.
          let!(:uuids) {
            ['11111111-2222-0000-0000-000000000000',
             '22222222-1111-0000-0000-000000000000',
             '00000000-3333-0000-0000-000000000000'].tap do |uuids|
               uuids.each_with_index do |uuid, index|
                store.with_session do |session|
                  tube = Laboratory::Tube.new
                  session << tube
                  ur = session.new_uuid_resource_for(tube)
                  ur.send(:uuid=, uuid)
                end
              end
            end
          }

          context "by label" do
            let!(:uuid) {
              store.with_session do |session|
                tube = session.tube[tube_id]
                session.uuid_for!(tube)
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
    end
  end
end

