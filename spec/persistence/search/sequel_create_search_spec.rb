# Spec requirements
require 'actions/action_examples'
require 'persistence/sequel/store_shared'

#Model requirements
require 'lims-core/persistence/search/create_search'
require 'lims-core/persistence/search/search_persistor'

module Lims::Core
  module Persistence

    describe Search::CreateSearch, :search => true, :sequel => true do
      context "valid calling context" do

        include_context("for application",  "Test search creation")
        include_context "sequel store"
        let(:model_name) { "plate" }
        let(:criteria) {{ :id => 1 }}
        let(:description) { "search description" }

        subject {  described_class.new(:store => store, :user => user, :application => application)  do |a,s|
          a.description = description
          a.model = model_name
          a.criteria = criteria
        end
        }
  
        context "two identical searches" do 
          it "must not store a search if one similar already exists in the database" do
            expect do
              subject.call
              subject.call
            end.to change { db[:searches].count }.by(1) 
          end

          it "should return an existing search from database if the search already exists" do
            result = subject.call
            result_new_search = subject.call
            result[:search].should == result_new_search[:search]
          end
        end

      end
    end
  end
end

