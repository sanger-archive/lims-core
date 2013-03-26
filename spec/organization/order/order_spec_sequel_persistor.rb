# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/store_shared'

require 'persistence/sequel/order_lookup_filter_shared'

# Model requirements
require 'lims-core/persistence/sequel/store'

module Lims::Core
  module Organization
    describe Order  do
      include_context "sequel store"

      def load_order(order_id)
        store.with_session do |session|
          yield( session.order[order_id])
        end
      end

      context "an empty order" do
        it "can be saved" do
          save(subject).should_not be_nil
        end

        context "being saved" do
          it "modifies the orders table" do
            expect { save(subject) }.to change { db[:orders].count }.by(1)
          end
        end
      end

      context "an order with items" do
        let(:source) { Order::Item.new }
        subject { Order.new(:items => { :source => [source]} ) }
        it "modifies the items table" do
          expect { save(subject) }.to change { db[:items].count }.by(1)
        end

        context "saved" do
          let!(:order_id) { save(subject) }
          let(:uuid_source2) { "11111111-1111-0000-0000-111111111111" }
          let(:uuid_source22) { "11111111-1111-0000-0000-222222222222" }

          it "can be reloaded" do
            store.with_session do |session|

              loaded = session.order[order_id]
              # testing object is well loaded
              loaded.should == subject

              # testing items are well loaded
              loaded[:source].should == subject[:source]
            end
          end

          it "can have empty items added" do
            load_order(order_id) do |order|
              order.add_target(:intermediate_target)
            end
            load_order(order_id) do |order|
              order[:intermediate_target].first.should be_an(Order::Item)
              order[:intermediate_target].first.status.should == "pending"
            end
          end


          it "can have non-empty items added" do
            load_order(order_id) do |order|
              order.add_source(:source2, uuid_source2)
              order.add_source(:source2, uuid_source22)
            end

            load_order(order_id) do |order|
              [uuid_source2, uuid_source22].zip(order[:source2]) do |uuid, item|
                item.done?.should == true
                item.status.should == "done"
                item.uuid.should == uuid
              end
            end

          end

          let(:long_attribute) { (1..50).inject("") { |s,i|  s+"#{i}-abcdefghi" } }
          let(:state) { {:my_state => 34, :state => :hidden, :long_attribute => long_attribute } }
          it "can its state updated with a really long state" do
            load_order(order_id) do |order|
              order.state = state
            end

            load_order(order_id) do |order|
              order.state.should == state
            end
          end
          let(:parameters) { {:read_length => 102, :hash => { :long_attribute => long_attribute}} }
          it "can its parameters updated with a really long parameters" do
            load_order(order_id) do |order|
              order.parameters = parameters
            end

            load_order(order_id) do |order|
              order.parameters.should == parameters
            end
          end


          context "with an intermediate item" do
            subject { Order.new.tap { |o| o.add_target(:intermediate_target) } }
            it "can have item's state updated" do
              load_order(order_id) do |order|
                order[:intermediate_target].each(&:start)
              end
              load_order(order_id) do |order|
                order[:intermediate_target].each { |item| item.status.should == "in_progress" }
              end
            end
          end
          
          context "with an intermediate item in progress"  do
            let(:item_uuid) { "11111111-1111-1111-0000-000000000000" }
            subject do Order.new.tap do |o|
              o.add_target(:intermediate_target);  
              o[:intermediate_target].each &:start
            end
            end
            it "can have item's uuid updated" do
              load_order(order_id) do |order|
                order[:intermediate_target].first.uuid =  item_uuid
              end
              load_order(order_id) do |order|
                order[:intermediate_target].first.uuid.should == item_uuid
              end
            end
          end

          context "with an item assigned to a batch" do
            let(:batch) { Organization::Batch.new }
            let(:item) { Order::Item.new(:batch => batch) }
            subject do 
              Order.new.tap do |order|
                order[:role] = []
                order[:role] << item
              end
            end

            it "saves item batch" do
              load_order(order_id) do |order|
                order["role"].first.batch.should == batch
              end
            end
          end

          it "saves its status" do
            load_order(order_id) do |order|
              order.cancel
            end
            load_order(order_id) do |order|
              order.cancel?.should == true
            end
          end
        end
      end

      context "with a creator" do
        let(:creator) { User.new }
        subject { Order.new(:creator => creator) }

        it "can be saved reloaded" do
          order_id = save(subject)

          load_order(order_id) do |order|
            order.creator.should == creator
          end
        end
      end

      context "#lookup" do
        it_behaves_like "searchable by item criteria"
      end
    end
  end
end
