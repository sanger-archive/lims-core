# Spec requirements
require 'persistence/sequel/spec_helper'

require 'persistence/sequel/store_shared'
require 'persistence/sequel/page_shared'


# Model requirements
require 'lims/core/persistence/sequel/search'

require 'logger'
module Lims::Core
  module Persistence

    describe Sequel::Search  do
      include_context "sequel store"

      context "holding a multi criteria filter" do
        let(:criteria) { {:id => 3, :name => "a name" } }
        let(:filter) { MultiCriteriaFilter.new(criteria) }
        let(:model) { mock(:model) }
        subject { Persistence::Search.new( :model => model, :filter => filter) }

        context "created and added to session" do
          it "modifies the searches table" do
            expect do
              store.with_session { |s| s << subject }
            end.to change { db[:searches].count }.by(1)
          end

          it "should be reloadable" do
            search_id = save(subject)
            store.with_session do |session|
              session.search[search_id].should == subject
            end
          end
        end

        context "created but not added to a session" do
          it "should not be saved" do
            expect do 
              store.with_session { |_| subject }
            end.to change{ db[:searches].count }.by(0)
          end 
        end
      end
    end
  end
end

