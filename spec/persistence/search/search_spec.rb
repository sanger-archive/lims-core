require 'persistence/sequel/store_shared'

require 'lims-core/persistence/search'
require 'lims-core/persistence/search/create_search'
require 'lims-core/persistence/multi_criteria_filter'
require 'lims-core/persistence/sequel/persistor'

module Lims::Core::Persistence
  describe "Search::CreateSearch" do
    def creating_a_search(description, model, filter)
      Search.new( :description => description,
                  :model => model, 
                  :filter => filter).tap do |search|
        store.with_session do |session|
          debugger
          session << search
          uuid = session.uuid_for!(search)
        end
      end
    end

    include_context "sequel store"

    let(:description)       { "search for a plate by ids" }
    let(:model)             { nil }
    let(:model_for_action)  { "plate" }
    let(:criteria)          { { "id" => [1,2]} }
    let(:criteria_for_act)  { { "id" => [1,2]} }
    let(:filter)            { MultiCriteriaFilter.new(:criteria => criteria) }
    let(:existing_search) { creating_a_search(description, model, filter)}

    before {
      Lims::Core::Persistence::Persistor.any_instance.stub(
        :filter_attributes_on_save).with(:attributes) do
        debugger
        puts 1233
      end
    }

    subject do
      Search::CreateSearch.new(:store => store, :user => user, :application => application)  do |a,s|
        a.description = description
        a.model       = model_for_action
        a.criteria    = criteria_for_act
      end
    end

    context "creating 2 or more similar search should not crash the DB" do
      it {
        creating_a_search(description, model, filter).should be_a(Search)
        result = subject.call
        result.should be_a Hash
        result[:search].tap do |returned_search|
          returned_search.description.should == existing_search.description
          returned_search.model.should == existing_search.model
          returned_search.filter.should == existing_search.filter
        end
      }
    end
  end
end
