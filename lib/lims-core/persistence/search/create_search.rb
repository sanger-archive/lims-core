# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-core/labels/labellable/label_filter'
require 'lims-core/organization/order/order_filter'
require 'lims-core/organization/batch/batch_filter'
require 'lims-core/persistence/search/search_persistor'
require 'lims-core/persistence/multi_criteria_filter'
require 'lims-core/persistence/comparison_filter'

module Lims::Core
  module Persistence
    class Search
      class CreateSearch
        include Actions::Action

        attribute :description, String, :required => true
        attribute :model, String, :required => true
        attribute :criteria, Hash, :required => true

        def _call_in_session(session)
          # Create the appropriate filter depending on the criteria
          # @tod remove hardcoded class
          keys = criteria.keys
          keys.delete("comparison") if criteria.keys.size > 1
          filter = case [keys.size, keys.first.to_s]
                   when [1, "label"] then Persistence::LabelFilter.new(:criteria => criteria, :model => model)
                   when [1, "order"] then Persistence::OrderFilter.new(:criteria => criteria, :model => model)
                   when [1, "batch"] then Persistence::BatchFilter.new(:criteria => criteria, :model => model)
                   when [1, "comparison"] then Persistence::ComparisonFilter.new(:criteria => criteria, :model => model)
                   else Persistence::MultiCriteriaFilter.new(:criteria => criteria)
                   end

          search = Persistence::Search.new(:description => description, 
                                           :model => session.send(model).model, 
                                           :filter => filter)
          if search.valid?   
            stored_search = session.search[search.attributes]
            if stored_search.nil?
              session << search
            else 
              search = stored_search
            end
            { :search => search, :uuid => session.uuid_for!(search) }
          else
            false
          end
        end
      end
    end
  end
  module Persistence
    class Search
      Create = CreateSearch
    end
  end
end
