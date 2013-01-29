# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'


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
        let!(:store) { Persistence::Store.new() }
        include_context("for application",  "Test search creation")

        before do
          Lims::Core::Persistence::Session.any_instance.tap do |session|
            session.stub(:search) {
              mock(:search).tap do |s|
              s.stub(:[]) 
              end
            }
          end
        end

        context "valid" do
          let(:model_name) { "plate" }
          let(:model) { Laboratory::Plate }
          let(:criteria) {{ :id => 1 }}
          let(:description) { "search description" }

          subject {  CreateSearch.new(:store => store, :user => user, :application => application)  do |a,s|
            a.description = description
            a.model = model_name
            a.criteria = criteria
          end
          }

          it_behaves_like "creating a search"

          context "with label criteria" do
            include_context "create object"
            let(:criteria) {{ :label => {:position => "front barcode"}}}
            it "uses a LabelFilter" do
              result = subject.call
              result.should be_a Hash
              search = result[:search]
              search.should be_a Persistence::Search
              search.filter.should be_a(Persistence::LabelFilter) 
            end
          end

          context "with order criteria" do
            include_context "create object"
            let(:criteria) { {:order => {:item => {:status => "pending"}, :status => "pending"}} }
            it "uses an OrderFilter" do
              result = subject.call
              result.should be_a Hash
              search = result[:search]
              search.should be_a Persistence::Search
              search.filter.should be_a(Persistence::OrderFilter)
            end
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

