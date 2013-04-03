# Spec requirements
require 'persistence/sequel/spec_helper'

require 'persistence/sequel/store_shared'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/laboratory/oligo/oligo_persistor'

module Lims::Core

  describe "Laboratory::Oligo::OligoSequelPersistor", :oligo => true, :laboratory => true, :persistence => true, :sequel => true do
    include_context "prepare tables"
    let(:db) { ::Sequel.sqlite('') }
    let(:store) { Persistence::Sequel::Store.new(db) }
    before (:each) { prepare_table(db) }

    let (:oligo) { Laboratory::Oligo.new ("AAA") }

    context "when created within a session" do
      it "should modify the  oligos table" do
        expect do
          store.with_session { |session| session << oligo }
        end.to change { db[:oligos].count}.by(1) 
      end
    end

    it "should save it" do
      oligo_id = store.with_session do |session|
        session << oligo
        lambda { session.id_for(oligo) }
      end.call 

      store.with_session do |session|
        session.oligo[oligo_id].sequence == oligo.sequence
        session.oligo[oligo_id]== oligo
      end
    end
  end
end
