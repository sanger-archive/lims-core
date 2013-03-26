# Spec requirements
require 'persistence/sequel/spec_helper'

require 'persistence/sequel/store_shared'
require 'persistence/sequel/page_shared'
require 'persistence/resource_shared'


# Model requirements
require 'lims-core/persistence/search/search_sequel_persistor'
require 'lims-core/laboratory/plate'
require 'lims-core/persistence/filter/order_filter'

require 'logger'
module Lims::Core

  module Persistence

    describe Sequel::Search  do
      include_context "sequel store"

      context "holding a multi criteria filter" do
        let(:criteria) { {:id => 3, :name => "a name" } }
        let(:filter) { MultiCriteriaFilter.new(criteria) }
        let(:model) { Laboratory::Plate }
        subject { Persistence::Search.new( :model => model, :filter => filter) }

        it_behaves_like "storable resource", :search, {:searches => 1 }
      end

      context "holding an order filter" do
        let(:criteria) { {:order => {:item => {:status => "in_progress"}, :status => "pending"}} }
        let(:filter) { OrderFilter.new(criteria) }
        let(:model) { Laboratory::Plate }
        subject { Persistence::Search.new(:model => model, :filter => filter) }
        
        it_behaves_like "storable resource", :search, {:searches => 1}
      end
    end
  end
end

