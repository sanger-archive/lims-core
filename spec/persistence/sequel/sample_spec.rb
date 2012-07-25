# Spec requirements
require 'persistence/sequel/spec_helper'

require 'persistence/sequel/store_shared'

# Model requirements
require 'lims/core/persistence/sequel/store'
require 'lims/core/laboratory/sample'

module Lims::Core

  describe Persistence::Sample do
    include_context "prepare tables"
    let(:db) { ::Sequel.sqlite('') }
    let(:store) { Persistence::Sequel::Store.new(db) }
    before (:each) { prepare_table(db) }

    let (:sample) { Laboratory::Sample.new(:name => "Sample 1") }

    context "when created within a session" do
      it "should modify the  samples table" do
        expect do
          store.with_session { |session| session << sample }
        end.to change { db[:samples].count}.by(1) 
      end
    end

    it "should save it" do
      sample_id = store.with_session do |session|
        session << sample
        lambda { session.id_for(sample) }
      end.call 

      store.with_session do |session|
        session.sample[sample_id].name == sample.name
        session.sample[sample_id]== sample
      end
    end
  end
end
