# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/page_shared'

require 'lims/core/persistence/multi_criteria_filter'

module Lims::Core
  module Persistence
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
      context "no orders" do
      end
      context "saved orders" do
        let(:basic_parameters) { { :creator => Organization::User.new(), :study => Organization::Study.new(), :pipeline => "testing" } }
        let(:orders) {
          # We give a different pipeline to be able to differentiate each order easily
          # and sort them
          [
            Organization::Order.new(basic_parameters.merge(:pipeline => "P1")).tap do |o|
              o.add_source("source1", "1111-1111-00000000-000000000000")
              o.add_target("source2", "1111-2222-00000000-000000000000")
              o.add_source("source3", "0000-3333-00000000-000000000000")
              o.build!
              o.start!
            end,
            Organization::Order.new(basic_parameters.merge(:pipeline => "P2")).tap do |o|
              o.add_source("source1", "2222-1111-00000000-000000000000")
              o.add_source("source2", "2222-2222-00000000-000000000000")
              o.add_target("source3", "0000-3333-00000000-000000000000")
              o.build!
              o.start!
            end,
            Organization::Order.new(basic_parameters.merge(:pipeline => "P3")).tap do |o|
              o.add_source("source1", "3333-1111-00000000-000000000000")
              o.add_source("source2", "3333-2222-00000000-000000000000")
              o.add_target("target1", "0000-3333-00000000-000000000000") # common
              #o.add_target("target2", "1111-1111-00000000-000000000000")
              o.build!
              o.start!
              o.complete!
            end
          ]
        }
        let!(:ids) {
          orders.map do |o|
            save(o)
          end
        }

        context "lookup by one uuid" do
          it_behaves_like "finding orders", { :item => {:uuid => "1111-2222-00000000-000000000000" } }, [0]
          context "find 2 orders" do
            it_behaves_like "finding orders", { :item => {:uuid => "0000-3333-00000000-000000000000" } }, [0,1,2]
          end

        end

        context "lookup by role" do
            it_behaves_like "finding orders", { :item => {:role => "source3"} }, [0,1]
            it_behaves_like "finding orders", { :item => {:role => %w[source3 target1] } }, [0,1,2]
        end

        context "lookup by status" do
            it_behaves_like "finding orders", { :item => {:uuid => "0000-3333-00000000-000000000000", :status => "pending" } }, [1,2]
        end

        context "lookup by role and uuid and status" do
            it_behaves_like "finding orders", { :item => { :role => "source3", :status => "pending", :uuid => "0000-3333-00000000-000000000000" } }, [1]
        end

        context "mix order and items criteria" do
          it_behaves_like "finding orders", { :status => "completed", :item => { :uuid => "0000-3333-00000000-000000000000" } }, [2]
        end
      end
    end
  end
end
