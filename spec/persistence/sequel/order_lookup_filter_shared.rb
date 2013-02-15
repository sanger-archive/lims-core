# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/page_shared'

require 'lims/core/persistence/multi_criteria_filter'
require 'lims/core/persistence/order_filter'

module Lims::Core
  module Persistence
    shared_context "with saved orders" do
      include_context "with saved batches"
      let(:basic_parameters) { { :creator => Organization::User.new(), :study => Organization::Study.new(), :pipeline => "testing" } }
      let(:orders) {
        # We give a different pipeline to be able to differentiate each order easily
        # and sort them
        [
          Organization::Order.new(basic_parameters.merge(:pipeline => "P1")).tap do |o|
            o.add_source("source1", "11111111-1111-0000-0000-000000000000")
            o.add_target("source2", "11111111-2222-0000-0000-000000000000")
            o.add_source("source3", "00000000-3333-0000-0000-000000000000")
            o.build!
            o.start!
          end,
          Organization::Order.new(basic_parameters.merge(:pipeline => "P2")).tap do |o|
            o.add_source("source1", "22222222-1111-0000-0000-000000000000")
            o.add_source("source2", "22222222-2222-0000-0000-000000000000")
            o.add_target("source3", "00000000-3333-0000-0000-000000000000")
            o.build!
            o.start!
          end,
          Organization::Order.new(basic_parameters.merge(:pipeline => "P3")).tap do |o|
            o.add_source("source1", "33333333-1111-0000-0000-000000000000")
            o.add_source("source2", "33333333-2222-0000-0000-000000000000")
            o.add_target("target1", "00000000-3333-0000-0000-000000000000")
            o.build!
            o.start!
            o.complete!
          end
        ]
      }
      let!(:ids) {
        orders.map do |o|
          store.with_session do |session|
            session << o
            o[:source2].first.batch = session[batch_uuids[0]] if o.pipeline == 'P1'
            o[:source1].first.batch = session[batch_uuids[1]] if o.pipeline == 'P2'
            o[:target1].first.batch = session[batch_uuids[0]] if o.pipeline == 'P3'
          end
        end
      }
    end

    shared_context "with saved batches" do
      let!(:batch_uuids) do
        ['11111111-2222-2222-3333-000000000000', '11111111-2222-2222-3333-111111111111'].tap do |uuids|
          uuids.each do |uuid|
            store.with_session do |session|
              batch = Organization::Batch.new
              session << batch
              ur = session.new_uuid_resource_for(batch)
              ur.send(:uuid=, uuid)
            end
          end
        end
      end
    end

    shared_examples_for "finding orders" do |criteria, indexes|
      let(:filter) { MultiCriteriaFilter.new(criteria)
      }
      let(:persistor) { store.with_session { |s| filter.call(s.order) } }
      context do
        it "find the right orders" do
          loaded = persistor.slice(0, orders.size).to_a.sort { |a,b| a.pipeline <=> b.pipeline }
          original = indexes.map { |i| orders[i]}.sort { |a,b| a.pipeline <=> b.pipeline }

          loaded.should == original

        end
        it "find the correct number of order" do
          persistor.count.should == indexes.size
        end
      end
    end

    shared_examples_for "searchable by item criteria" do
      context "saved orders" do
        include_context "with saved orders"

        context "lookup by one uuid" do
          it_behaves_like "finding orders", { :item => {:uuid => "11111111-2222-0000-0000-000000000000" } }, [0]
          context "find 2 orders" do
            it_behaves_like "finding orders", { :item => {:uuid => "00000000-3333-0000-0000-000000000000" } }, [0,1,2]
          end
        end

        context "lookup by role" do
          it_behaves_like "finding orders", { :item => {:role => "source3"} }, [0,1]
          it_behaves_like "finding orders", { :item => {:role => %w[source3 target1] } }, [0,1,2]
        end

        context "lookup by status" do
          it_behaves_like "finding orders", { :item => {:uuid => "00000000-3333-0000-0000-000000000000", :status => "pending" } }, [1,2]
        end

        context "lookup by role and uuid and status" do
          it_behaves_like "finding orders", { :item => { :role => "source3", :status => "pending", :uuid => "00000000-3333-0000-0000-000000000000" } }, [1]
        end

        context "mix order and items criteria" do
          it_behaves_like "finding orders", { :status => "completed", :item => { :uuid => "00000000-3333-0000-0000-000000000000" } }, [2]
        end
      end
    end

    shared_examples_for "finding resources" do |uuids|
      it "finds the resource" do
        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0, uuids.size).to_a
          all.size.should == uuids.size

          uuids.each do |uuid|
            all.should include(session[uuid])
          end

          all.each do |resource|
            resource.should be_a(model)
          end
        end
      end 
    end

    shared_examples_for "orders filtrable" do
      include_context "with saved orders"
      let(:description) { "lookup by order" }
      let(:filter) { Persistence::OrderFilter.new(criteria) }
      let(:search) { Persistence::Search.new(:model => model, :filter => filter, :description => description) }

      context "by order pipeline" do
        let(:criteria) { {:order => {:pipeline => "P1"}} }
        it_behaves_like "finding resources", ['11111111-2222-0000-0000-000000000000', '00000000-3333-0000-0000-000000000000'] 
      end

      context "by order status" do
        let(:criteria) { {:order => {:status => "in_progress"}} }
        it_behaves_like "finding resources", ['22222222-1111-0000-0000-000000000000','11111111-2222-0000-0000-000000000000', '00000000-3333-0000-0000-000000000000']
      end
      
      context "by order item" do
        let(:criteria) { {:order => {:item => {:status => "pending"}}} }
        it_behaves_like "finding resources", ['11111111-2222-0000-0000-000000000000']
      end

      context "by batch assigned to order items" do
        let(:criteria) { {:order => {:item => {:batch => {:uuid => '11111111-2222-2222-3333-000000000000'}}}} }
        it_behaves_like "finding resources", ['11111111-2222-0000-0000-000000000000', '00000000-3333-0000-0000-000000000000']
      end
   end
  end
end
