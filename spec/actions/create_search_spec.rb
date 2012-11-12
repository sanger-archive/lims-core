# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'
require 'persistence/sequel/store_shared'

#Model requirements
require 'lims/core/actions/create_search'
require 'lims/core/persistence/search'
require 'lims/core/laboratory/plate'

module Lims::Core
  module Actions

    shared_examples_for "creating a search" do
      include_context "create object"
      it_behaves_like "an action"
      it "create a search object" do
        result = subject.call
        result.should be_a Hash

        search = result[:search]
        search.should be_a Persistence::Search
        search.model.should == model
        search.filter.criteria.should == criteria
      end
    end

    describe CreateSearch do
      context "valid calling context" do
        include_context("for application",  "Test search creation")

        context "valid" do
          let(:store) { Persistence::Store.new() }
          let(:model_name) { "plate" }
          let(:model) { Laboratory::Plate }
          let(:criteria) {{ :id => 1 }}
          
          subject {  CreateSearch.new(:store => store, :user => user, :application => application)  do |a,s|
            a.model = model_name
            a.criteria = criteria
          end
          }
          
          it_behaves_like "creating a search"
        end

        context "two identical searches" do 
          include_context("for application", "Test search")
          include_context "sequel store"
          let(:model_name) { "plate" }
          let(:criteria) {{ :id => 1 }}

          subject {
            CreateSearch.new(:store => store, :user => user, :application => application) do |a,s|
              a.model = model_name
              a.criteria = criteria
            end 
          }
         
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

        context "invalid" do
          context "criteria not matching column" do
            let(:model_name) { "plate" }
            let(:model) { Laboratory::Plate }
            let(:criteria)  { { :dummy_attribute => :test } } 

            pending "needs implementatio" do
              it "should raise an error" do
                subject.call.should == false
              end
            end
          end
        end
      end
    end
  end
end

