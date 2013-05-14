# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

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
          # Use the appropriate filter if needed.
          filter = nil
          if criteria.size == 1 
            criteria.keys.first.andtap do |model|
              filter_class_name = "#{model.capitalize}Filter"
              if Persistence::const_defined? filter_class_name
                filter = Persistence::const_get(filter_class_name).new(:criteria => criteria)
              end
            end
          end
          filter ||= Persistence::MultiCriteriaFilter.new(:criteria => criteria)
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
