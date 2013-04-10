# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

#Model requirements
require 'lims-core/organization/order/create_order'

module Lims::Core
  module Organization
    describe Order::CreateOrder, :order => true, :organization => true, :persistence => true do
      shared_examples_for "creating an order" do
        include_context "create object"
        it_behaves_like "an action"

        it "creates an order object" do
          Persistence::Session.any_instance.should_receive(:save)
          result = subject.call 
          order = result[:order]
          order.should be_a Organization::Order
          order.creator.should == user
          order.pipeline.should == pipeline
          order.parameters.should == parameters
          order.study.should == study
          order.cost_code.should == cost_code 
          order.should_not respond_to(:items)

          sources.each do |role, uuid| 
            order[role].each do |item|
              item.should_not be_nil
              item.uuid.should == uuid
              item.done?.should == true
            end
          end 

          targets.each do |role, uuid|
            order[role].each do |item|
              item.should_not be_nil
              item.uuid.should == uuid
              item.pending?.should == true
            end
          end
        end
      end

      let!(:store) { Persistence::Store.new() }

      let(:pipeline) { mock(:pipeline) }
      let(:parameters) { mock(:parameters) }
      let(:sources) { {:source_role => mock(:source)} } 
      let(:targets) { {:target_role => mock(:target)} } 
      let(:study) { mock(:study) }
      let(:cost_code) { mock(:cost_code) }

      let(:create_order_parameters) { 
        { :store => mock(:store),
          :user => mock(:user),
          :application => "my application",
          :pipeline => pipeline,
          :parameters => parameters,
          :sources => sources,
          :targets => targets,
          :study => study,
          :cost_code => cost_code }
      }

      context "to be valid" do
        it do
          s = described_class.new(create_order_parameters)
          described_class.new(create_order_parameters).valid?.should == true
        end

        it "requires a cost code" do
          described_class.new(create_order_parameters - [:cost_code]).valid?.should == false
        end  
      end

      context "valid calling context" do
        include_context("for application",  "Test order creation")

        subject {
          Order::CreateOrder.new(:store => store, :user => user, :application => application) do |a,s|
            a.pipeline = pipeline
            a.parameters = parameters
            a.sources = sources
            a.targets = targets
            a.study = study
            a.cost_code = cost_code
          end
        }

        it_behaves_like "creating an order"
      end
    end
  end
end

