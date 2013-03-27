# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/store_shared'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/organization/batch'

module Lims::Core
  describe Organization::Batch, :batch => true, :organization => true,  :sequel => true  do
    include_context "prepare tables" 
    let(:db) { ::Sequel.sqlite('') }
    let(:store) { Persistence::Sequel::Store.new(db) }
    before(:each) { prepare_table(db) }


    context "create a batch and add it to session" do
      it "modifies the batches table" do
        expect do
          store.with_session { |s| s << subject }
        end.to change { db[:batches].count }.by(1)
      end

      it "reloads the batch" do
        batch_id = save(subject)
        store.with_session do |session|
          batch = session.batch[batch_id]
          batch.should eq(session.batch[batch_id])
        end
      end
    end


    context "create a batch but don't add it to a session" do
      it "is not saved" do
        expect do 
          store.with_session { |_| subject }
        end.to change{ db[:batches].count }.by(0)
      end 
    end
  end
end
