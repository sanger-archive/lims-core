require 'persistence/sequel/revision/spec_helper'

require 'lims-core/persistence/user_session'
require 'lims-core/persistence/sequel/user_session_sequel_persistor'


module Lims::Core
  module Persistence
    module Sequel
      describe  Revision::Session do
        context "With sql test store" do
          include_context "sqlite db"
          include_context "with test store"

          let(:session_id) { 1 }
          subject { described_class.new(store, session_id)  }
          it "creates revision persistors" do
            subject.name.is_a?(Sequel::Persistor).should == true
            subject.name.is_a?(Sequel::Revision::Persistor).should == true
          end
        end
      end
    end
  end
end
