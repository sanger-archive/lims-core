# Spec requirements
require 'persistence/sequel/spec_helper'

require 'persistence/sequel/store_shared'
require 'laboratory/tube_shared'
require 'persistence/sequel/label_filter_shared'

# Model requirements
require 'lims/core/persistence/sequel/store'
require 'lims/core/laboratory/tube'

module Lims::Core
  describe Laboratory::Tube do
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
              tube<< aliquot
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

        context "#lookup by label" do
          let!(:uuid) {
            store.with_session do |session|
              tube = session.tube[tube_id]
              session.uuid_for!(tube)
            end
          }

          it_behaves_like "labels filtrable"
        end
      end
    end
  end
end

