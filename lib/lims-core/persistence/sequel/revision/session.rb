require 'lims-core/persistence/sequel/session'
require 'lims-core/persistence/sequel/revision/persistor'

module Lims::Core
  module Persistence
    module Sequel
      module Revision
      # A RevisionSession is a session reading through
      # the revision table instead of the "normal" table.
      # To do so, it extends all the persistors to change
        # their table name and add a session_id constraints on the were clause
        class Session < Sequel::Session
          def initialize(store, session_id)
            @store = store
            @session_id = session_id
            super(store)
          end

          def new_persistorX(*args, &block)
            super(*args, &block).tap do |persistor|
              persistor.extend(Sequel::RevisionPersistor)
            end
          end
        end
      end
    end
  end
end
