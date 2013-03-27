# Spec requirements
require 'persistence/sequel/store_shared'
require 'persistence/sequel/spec_helper'
require 'laboratory/tube_shared'
require 'persistence/sequel/label_filter_shared'

# Model requirements
require 'lims-core/laboratory/spin_column'

module Lims::Core
  describe Laboratory::SpinColumn, :spin_column => true, :laboratory => true, :sequel => true do
    include_context "sequel store"
    
    context "created and added to session" do
      it "modifies the spin column table" do
        expect do
          store.with_session { |session| session << subject }
        end.to change { db[:spin_columns].count }.by(1)
      end

      it "should be reloadable" do
        spin_column_id = save(subject)
        store.with_session do |session|
          spin_column = session.spin_column[spin_column_id]
          spin_column.should eq(session.spin_column[spin_column_id])
        end
      end

      context "created but not added to a session" do
        it "should not be saved" do
          expect do 
            store.with_session { |_| subject }
          end.to change{ db[:spin_columns].count }.by(0)
        end 
      end

      context "already created spin  column" do
        let(:aliquot) { new_aliquot }
        let!(:spin_column_id) { save(subject) }

        context "when modified within a session" do
          before do
            store.with_session do |s|
              spin_column = s.spin_column[spin_column_id]
              spin_column << aliquot
            end
          end
          it "should be saved" do
            store.with_session do |session|
              spin_column = session.spin_column[spin_column_id]
              spin_column.should == [aliquot]
            end
          end
        end

        context "when modified outside a session" do
          before do
            spin_column = store.with_session do |s|
              s.spin_column[spin_column_id]
            end
            spin_column << aliquot
          end
          it "should not be saved" do
            store.with_session do |session|
              spin_column = session.spin_column[spin_column_id]
              spin_column.should be_empty
            end
          end
        end

        context "#lookup by label" do
          let!(:uuid) {
            store.with_session do |session|
              spin_column = session.spin_column[spin_column_id]
              session.uuid_for!(spin_column)
            end
          }

          it_behaves_like "labels filtrable"
        end
      end
    end
  end
end
