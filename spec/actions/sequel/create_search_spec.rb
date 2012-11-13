# Spec requirements
require 'actions/action_examples'
require 'persistence/sequel/store_shared'

#Model requirements
require 'lims/core/actions/create_search'
require 'lims/core/persistence/search'

module Lims::Core
  module Actions

    describe CreateSearch do
      context "valid calling context" do

        include_context("for application",  "Test search creation")
        include_context "sequel store"
        let(:model_name) { "plate" }
        let(:criteria) {{ :id => 1 }}

        subject {  CreateSearch.new(:store => store, :user => user, :application => application)  do |a,s|
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
            result.should == result_new_search 
          end
        end

      end
    end
  end
end

