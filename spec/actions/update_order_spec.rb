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
      let(:post_init_event) { [] }
    end

    shared_context "no items" do
      let(:order_items) { { } }
    end

    shared_examples_for "items" do
      let(:pending_uuid) { "11111111-1111-0000-0000-111111111111" }
      let(:in_progress_uuid) { "11111111-1111-0000-0000-222222222222" }
      let(:done_uuid) { "11111111-1111-0000-0000-333333333333" }
      let(:item) { Organization::Order::Item.new(:uuid =>   new_uuid) }
      let(:role) { "role" } 
      let(:order_items) { { "pending" => [Organization::Order::Item.new(:uuid => pending_uuid)],
          "in_progress" => [Organization::Order::Item.new(:uuid => in_progress_uuid).tap { |i| i.start! }],
          "done" => [Organization::Order::Item.new(:uuid => done_uuid).tap { |i| i.complete! }]
        }
      }
    end

    shared_examples_for "adding items" do |event=nil, new_status=nil|
      let(:new_uuid) { "22222222-1111-0000-0000-111111111111" }
      include_context "order updated"
      let(:parameters) { item_parameters.tap { |h| h[:event] = event if event } }
      context "add pending item#{event} and set send #{event}" do
        let(:item_parameters) { { :items => { "role1" => { new_uuid => {}  } } } }
        it "has a new role" do
          updated_order.should  include("role1")
        end
        it "has the correct item"  do
          updated_order["role1"].first.uuid.should == new_uuid
        end
        it "'s item has the correct status_name" do
          updated_order["role1"].first.status_name.should == :pending
        end

        it "has the correst status " do
          new_status ||= order.status
          updated_order.status.should == new_status
        end
      end
      context "add pending item at the end#{ event and "set send #{event}"}" do
        let(:item_parameters) { { :items => { "role1" => { "last" => {  "uuid" => new_uuid } } } } }
        it "has a new role" do
          updated_order.should  include("role1")
        end
        it "has the correct item"  do
          updated_order["role1"].first.uuid.should == new_uuid
        end
        it "'s item has the correct status_name" do
          updated_order["role1"].first.status_name.should == :pending
        end

        it "has the correct status " do
          new_status ||= order.status
          updated_order.status.should == new_status
        end
      end
      # skiping status_name
      context "add done item in existing role" do
        let(:item_parameters) { { :items => { "done" => { new_uuid => { "event" => :complete } } } } }
        it "has the correct item"  do
          updated_order["done"].last.uuid.should == new_uuid
        end
        it "has the correct status_name" do
          updated_order["done"].last.status_name.should == :done
        end

        it "has the correst status " do
          new_status ||= order.status
          updated_order.status.should == new_status
        end
      end
      context "add done item" do
        let(:item_parameters) { { :items => { "role1" => { new_uuid => { "event" => :complete } } } } }
        it "has a new role" do
          updated_order.should  include("role1")
        end
        it "has the correct item"  do
          updated_order["role1"].first.uuid.should == new_uuid
        end
        it "has the correct status_name" do
          updated_order["role1"].first.status_name.should == :done
        end

        it "has the correst status " do
          new_status ||= order.status
          updated_order.status.should == new_status
        end
      end
      context "add failed item" do
        let(:item_parameters) { { :items => { "role1"=> { new_uuid => { "event" => :fail } } } } }

        it "has a new role" do
          updated_order.should  include("role1")
        end
        it "has the correct item"  do
          updated_order["role1"].first.uuid.should == new_uuid
        end
        it "has the correct status_name" do
          updated_order["role1"].first.status_name.should == :failed
        end

        it "has the correst status " do
          new_status ||= order.status
          updated_order.status.should == new_status
        end
      end
      context "add cancelled item" do
        let(:item_parameters) { { :items => { "role1" => {  new_uuid => { "event" => :cancel } } } } }
        it "has a new role" do
          updated_order.should  include("role1")
        end
        it "has the correct item"  do
          updated_order["role1"].first.uuid.should == new_uuid
        end
        it "has the correct status_name" do
          updated_order["role1"].first.status_name.should == :cancelled
        end

        it "has the correst status " do
          new_status ||= order.status
          updated_order.status.should == new_status
        end
      end
    end

    shared_examples_for "updating item" do |role, item_event, new_item_status, event=nil, new_status=nil|
      include_context "order updated"
      let(:parameters) { item_parameters.tap { |h| h[:event] = event if event } }
      context "#{item_event} #{role} item#{ event and "set send #{event}"}" do
        let(:item_parameters) { { :items => { role => { "0" => { "event" => item_event } } } } }
        it "has the correct item"  do
          updated_order.should include(role)
        end
        it "'s item has the correct status_name" do
          updated_order[role].first.status.should == new_item_status

        end

        it "has the correct status " do
          new_status ||= order.status
          updated_order.status.should == new_status
        end
      end
    end
    shared_examples_for "not updating item" do |role, item_event, event=nil, new_status=nil|
      include_context "order updated"
      let(:parameters) { item_parameters.tap { |h| h[:event] = event if event } }
      context "#{item_event} #{role} item#{ event and "set send #{event}"}" do
        let(:item_parameters) { { :items => { role => { "0" => { "event" => item_event } } } } }
        it "raise an error"  do
          expect { updated_order }.to raise_error StateMachine::InvalidTransition
        end
      end
    end

    shared_examples_for "update underlying items" do |event=nil, new_status=nil|
      #it_behaves_like "not updating items" do
      it_behaves_like "updating item", "pending", "start", "in_progress", event, new_status
      it_behaves_like "updating item", "in_progress", "complete", "done", event, new_status
      it_behaves_like "updating item", "in_progress", "fail", "failed", event, new_status
      it_behaves_like "updating item", "in_progress", "cancel", "cancelled", event, new_status
      it_behaves_like "not updating item", "done", "start", "in_progress"
    end


    shared_examples_for "order updaded" do
      include_context "update object"
      it_behaves_like "an action"
      context "order is already saved" do
        let!(:result) { action.call }
        it "updates the order" do |status_name|

          result.should be_a Hash

          updated_order = result[:order]
          update_order.should == expected_order
        end
      end
    end

    shared_context "order updated" do
      let(:order) { Organization::Order.new(order_creation_parameter.merge(:items => order_items)).tap do |order|
          post_init_event.each { |event| order.public_send("#{event}!")  }
        end
      }
      let(:result) { action.call }
      let(:updated_order) { result[:order] }
    end

    shared_context "updating variable" do |key, value|
      include_context "order updated"
      context key do
        let(:parameters) { { key => value  } }
        it do
          updated_order[key].should == value
        end

      end
    end
    shared_context "not updating variable" do |key|
      include_context "order updated"
      context key do
        let(:parameters) { { key => "dummy value"  } }
        it do
          expect { updated_order[key] }.to raise_error
        end

      end
    end

    shared_context "updating states" do
      it_behaves_like "updating variable", :pipeline, "new pipeline "
      it_behaves_like "updating variable", :parameters, {:my_param => :new_value }
      it_behaves_like "updating variable", :state, {:my_state => :new_value }
    end

    shared_context "changing status" do |event, new_status|
      context event do
        include_context "order updated"
        let(:parameters) { {:event => event} }
        it "set new status" do
          updated_order.status.should == new_status
        end
      end
    end
    shared_context "not changing status" do |event|
      context event do
        include_context "order updated"
        let(:parameters) { {:event => event} }
        it "fail" do
          expect {
            updated_order
          }.to raise_error StateMachine::InvalidTransition
        end
      end
    end

    shared_context "updatable draft order" do
      it_behaves_like "adding items"
      it_behaves_like "updating states"

      # only draft
      it_behaves_like "updating variable", :cost_code, "new cost code"
      it_behaves_like "updating variable", :creator, "new user"
      it_behaves_like "updating variable", :study, "new study"

      it_behaves_like "changing status", :build, "pending"
      it_behaves_like "adding items", :build, "pending"
      it_behaves_like "not changing status", :start
      it_behaves_like "changing status", :fail, "failed"
    end

    shared_context "updatable pending order" do
      it_behaves_like "adding items"
      it_behaves_like "updating states"

      it_behaves_like "not updating variable", :cost_code, "new cost code"
      it_behaves_like "not updating variable", :creator, "new user"
      it_behaves_like "not updating variable", :study, "new study"

      it_behaves_like "changing status", :start, "in_progress"
      it_behaves_like "adding items", :start, "in_progress"
      it_behaves_like "not changing status", :build
      it_behaves_like "changing status", :fail, "failed"
    end

    shared_context "frozen order" do
      pending "not implemented, we can't constraint to do update item depending on order state" do
        it_behaves_like "not updating item", "pending", "start"
        it_behaves_like "updating item", "pending", "start", "in_progress"
      end


      it_behaves_like "not updating variable", :cost_code, "new cost code"
      it_behaves_like "not updating variable", :creator, "new user"
      it_behaves_like "not updating variable", :study, "new study"
      pending do
        it_behaves_like "not updating variable", :pipeline, "new pipeline"
      end

      it_behaves_like "not changing status", :build
      it_behaves_like "not changing status", :start
      it_behaves_like "not changing status", :complete
    end

    describe UpdateOrder do
      context "valid calling context" do
        let!(:store) { Persistence::Store.new() }
        include_context("for application",  "Test search creation")
        let(:action) { described_class.new(:store => store , :user => user, :application => application) do |action, session|

            action.order = order
            action.ostruct_update(parameters)
          end
        }

        context do
          subject { action }
          it_behaves_like "an action"
        end

        context "saves stubbed" do
          include_context "create object" # stub all save


          context "draft order" do
            include_context "draft order"
            context "with no items" do
              include_context "no items"
              it_behaves_like "updatable draft order"

            end

            context "with items" do
              include_context "items"
              it_behaves_like "updatable draft order"
              it_behaves_like "update underlying items"
            end
          end

          context "pending order" do
            let(:order_creation_parameter) { {} }
            let(:post_init_event) { [ "build"]}
            context "with no items" do
              include_context "no items"
              it_behaves_like "updatable pending order"

            end

            context "with items" do
              include_context "items"
              it_behaves_like "updatable pending order"
              it_behaves_like "update underlying items"
            end
          end

          context "order in  progress" do
            let(:order_creation_parameter) { {} }
            let(:post_init_event) { %w[build start] }
            include_context "items"
            it_behaves_like "adding items"
            it_behaves_like "updating states"

            it_behaves_like "not updating variable", :cost_code, "new cost code"
            it_behaves_like "not updating variable", :creator, "new user"
            it_behaves_like "not updating variable", :study, "new study"

            it_behaves_like "changing status", :complete, "completed"
            it_behaves_like "adding items", :complete, "completed"
            it_behaves_like "not changing status", :build
            it_behaves_like "changing status", :fail, "failed"

          end

          context "failed order" do
            let(:order_creation_parameter) { {} }
            let(:post_init_event) { %w[build fail] }
            include_context "items"
            it_behaves_like "frozen order"
          end
          context "order done" do
            let(:order_creation_parameter) { {} }
            let(:post_init_event) { %w[build start complete] }
            include_context "items"
            it_behaves_like "frozen order"
          end
        end
      end
    end
  end
end

