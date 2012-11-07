# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/persistence/search'
require 'lims/core/persistence/multi_criteria_filter'

module Lims::Core
  module Actions
    class CreateSearch
      include Action

      attribute :model, String, :required => true
      attribute :criteria, Hash, :required => true

      def _call_in_session(session)
        filter = Persistence::MultiCriteriaFilter.new(:criteria => criteria)
        search = Persistence::Search.new(:model => session.send(model).model, :filter => filter)
        if search.valid?
          session << search
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
