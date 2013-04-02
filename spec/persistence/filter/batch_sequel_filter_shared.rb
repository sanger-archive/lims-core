require 'persistence/sequel/spec_helper'
require 'lims-core/persistence/filter/batch_filter'
require 'persistence/filter/order_lookup_sequel_filter_shared'

module Lims::Core
  shared_examples_for "batch filtrable" do
    include_context "with saved orders"
    let(:description) { "lookup resources by batch" }
    let(:filter) { Persistence::BatchFilter.new(criteria) }
    let(:search) { Persistence::Search.new(:model => model, :filter => filter, :description => description) }

    context "get resources by batch uuid criteria" do
      let(:criteria) { {:batch => {"uuid" => batch_uuids[1]}} }
      it "finds resources" do
        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0, 1000).to_a
          all.size.should == 1 
          all.should include(session['22222222-1111-0000-0000-000000000000'])
          all.first.should be_a(model)
        end
      end
    end

    context "get resources by multiple batch uuid criteria" do
      let(:criteria) { {:batch => {"uuid" => batch_uuids}} }
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
