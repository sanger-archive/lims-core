# Spec requirements
require 'persistence/sequel/spec_helper'

require 'laboratory/flowcell_shared'
require 'persistence/resource_shared'
require 'persistence/sequel/store_shared'
require 'persistence/sequel/page_shared'
require 'persistence/sequel/multi_criteria_filter_shared'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/laboratory/flowcell'

module Lims::Core
  shared_context "already created flowcell" do
    let(:aliquot) { new_aliquot }
    before (:each) do
      store.with_session { |session| session << new_empty_flowcell.tap {|_| _[0] << aliquot} }
    end
    let(:flowcell_id) { store.with_session { |session| @flowcell_id = last_flowcell_id(session) } }

    context "when modified within a session" do
      before do
        store.with_session do |s|
          flowcell = s.flowcell[flowcell_id]
          flowcell[0].clear
          flowcell[1]<< aliquot
        end
      end
      it "should be saved" do
        store.with_session do |session|
          f = session.flowcell[flowcell_id]
          f[7].should be_empty
          f[1].should == [aliquot]
          f[0].should be_empty
        end
      end
    end
    context "when modified outside a session" do
      before do
        flowcell = store.with_session do |s|
          s.flowcell[flowcell_id]
        end
        flowcell[0].clear
        flowcell[1]<< aliquot
      end
      it "should not be saved" do
        store.with_session do |session|
          f = session.flowcell[flowcell_id]
          f[7].should be_empty
          f[1].should be_empty
          f[0].should == [aliquot]
        end
      end
    end
  end

  describe "Sequel#Flowcell ", :flowcell => true, :laboratory => true, :sequel => true do
    include_context "prepare tables"
    let(:db) { ::Sequel.sqlite('') }
    let(:store) { Persistence::Sequel::Store.new(db) }
    let(:hiseq_number_of_lanes) { 8 }
    let(:miseq_number_of_lanes) { 1 }
    before (:each) { prepare_table(db) }

    include_context "flowcell factory"

    def last_flowcell_id(session)
      session.flowcell.dataset.order_by(:id).last[:id]
    end

    # execute tests with miseq flowcell
    context "miseql"  do
    let(:number_of_lanes) { miseq_number_of_lanes }
      subject { new_flowcell_with_samples(3) }
      it_behaves_like "storable resource", :flowcell, {:flowcells => 1, :lanes => 1*3 }

      pending "only works for hiseq"  do
        include_context "already created flowcell"
      end
    end

    # execute tests with hiseq flowcell
    context "hiseq"  do
    let(:number_of_lanes) { hiseq_number_of_lanes }

      subject { new_flowcell_with_samples(3) }
      it_behaves_like "storable resource", :flowcell, {:flowcells => 1, :lanes => 8*3 }
      include_context "already created flowcell"
    end

    context do
    let(:number_of_lanes) { hiseq_number_of_lanes }
    let(:constructor) { lambda { |*_| new_flowcell_with_samples } }
    it_behaves_like "paginable resource", :flowcell
    it_behaves_like "filtrable", :flowcell
    end
  end
end
