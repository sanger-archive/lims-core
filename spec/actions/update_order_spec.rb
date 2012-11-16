# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'


#Model requirements
require 'lims/core/actions/update_order'
require 'lims/core/organization/order'
module Lims::Core
  module Actions

    shared_context "draft order" do
      let(:order_creation_parameter) { {} }
    end

    shared_context "no items" do
      let(:order_items) { { } }
    end

    shared_examples_for "adding items" do
      include_context "order updated"
      context "add pending item" do
        let(:parameters) { { :items => { :role => { :item => "item1" } } } }
        it "add it"  do
          new_order.items[:role1].uuid.should == "item1"
          new_order.items.status.should == :pending
        end
      end
      # skiping status
      context "add done item" do
      end
      context "add failed item" do
      end
    end

    shared_examples_for "order updaded" do
      include_context "update object"
      it_behaves_like "an action"
      context "order is already saved" do
        let!(:result) { action.call }
        it "updates the order" do |status|

          result.should be_a Hash

          updated_order = result[:order]
          update_order.should == expected_order
        end
      end
    end

    shared_context "order updated" do
    let(:order) { Order.new(order_creation_parameter).tap do |order|
        order.public_send(event) if event
      end
    }
    let(:result) { action.call }
    let(:new_order) { result[:order] }
  end

  describe UpdateOrder do
    context "valid calling context" do
      let!(:store) { Persistence::Store.new() }
      include_context("for application",  "Test search creation")
      let(:action) { described_class.new(:store => store , :user => user, :application => application) do |action, session|

          action.ostruct_update(parameters)
        end
      }

      context "draft order with no items" do
        include_context "draft order"
        include_context "no items"

        it_behaves_like "adding items"

        context "update state"
        context "start order"

        context "update pipeline"
        context "update state" do
        end

        # only draft

        context "update cost code" do
        end

        context "update study" do
        end
        context "update  creator" do
        end
      end

      context "existing order with pending item" do
        context "start item" do
          context "complete item" do
          end
          context "fail item" do
          end
        end
        context "fail item" do
        end
        context "complete item" do
        end

        context "delete item" do
        end

        context "update underlying item" do
        end

      end

      context "pending order" do
        pending "same as draft"
        context "can be started" do
        end

        context "can't update cost code"
        context "can't update study"
        context "can't creator"
      end

      context "order in  progress" do
        context "can be completed"  do
          context "and update item at the same time" do
          end
        end
        context "can be failed" do
        end
      end

      context "failed order" do
        context "can't be modified"
      end
      context "order done" do
        context "can't be modified"
      end
    end
  end
end
end

