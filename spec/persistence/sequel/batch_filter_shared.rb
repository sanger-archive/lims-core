require 'persistence/sequel/spec_helper'
require 'lims/core/persistence/batch_filter'

module Lims::Core
  shared_context "with saved orders and items in different batches" do
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
          o[:source2].first.batch_uuid = batch_uuids[0]
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
          o[:target1].first.batch_uuid = batch_uuids[1]
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

  shared_examples_for "batch filtrable" do
    include_context "with saved orders and items in different batches"
    let(:description) { "lookup resources by batch" }
    let(:filter) { Persistence::BatchFilter.new(criteria) }
    let(:search) { Persistence::Search.new(:model => model, :filter => filter, :description => description) }

    context "get resources by batch uuid criteria" do
      let(:criteria) { {:batch => {:uuid => batch_uuids[0]}} }
      it "finds resources" do
        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0, 1000).to_a
          all.size.should == 1 
          all.should include(session['11111111-2222-0000-0000-000000000000'])
          all.first.should be_a(model)
        end
      end
    end

    context "get resources by multiple batch uuid criteria" do
      let(:criteria) { {:batch => {:uuid => batch_uuids}} }
      it "finds resources" do
        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0, 1000).to_a
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
  end
end
