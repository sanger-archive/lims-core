# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-core/persistence/search_persistor'
require 'lims-core/persistence/filter/multi_criteria_filter'
require 'lims-core/persistence/filter/label_filter'
require 'lims-core/persistence/filter/order_filter'
require 'lims-core/persistence/filter/batch_filter'

module Lims::Core
  module Persistence
    class Search::CreateSearch
      include Action

      attribute :description, String, :required => true
      attribute :model, String, :required => true
      attribute :criteria, Hash, :required => true

      def _call_in_session(session)
        # Create the appropriate filter depending on the criteria
        filter = case [criteria.size, criteria.keys.first.to_s]
                 when [1, "label"] then Persistence::LabelFilter.new(:criteria => criteria)
                 when [1, "order"] then Persistence::OrderFilter.new(:criteria => criteria)
                 when [1, "batch"] then Persistence::BatchFilter.new(:criteria => criteria)
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
  module Persistence
    class Search
      Create = Actions::CreateSearch
    end
  end
end
