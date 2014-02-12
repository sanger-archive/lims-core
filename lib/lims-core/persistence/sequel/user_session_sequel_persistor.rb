require 'lims-core/persistence/user_session_persistor'
require 'lims-core/persistence/sequel/persistor'

require 'lims-core/persistence/sequel/revision/session'
require 'lims-core/persistence/sequel/session_finder/session'
require 'lims-core/persistence/sequel/revision_finder/session'


module Lims::Core
  module Persistence
    class UserSession
      class UserSessionSequelPersistor < UserSessionPersistor
        include Sequel::Persistor
        def self.table_name
          :sessions
        end

        def bulk_insert(*args, &block)
          raise Persistence::Session::ReadonlyClassException.new(UserSession)
        end

        def session_ids_for(objects)
          case objects
          when Resource, ResourceState
            objects = [objects]
          end

          collect_user_session_states(objects)
        end

        # Find all the resources modified directly or 
        # indirecty by a session.
        def collect_user_session_states(objects)
          #

          Sequel::SessionFinder::Session.new(@session.store).with_session do |finder_session|
            finder_session.load_from_external_states(objects, @session)
            finder_session.session_ids.to_a.sort
        end

        end

        def collect_direct_states(user_session)
          StateList.new(@session.revision.dataset.filter(:session_id => user_session.id).map do |row|
            persistor = @session.persistor_for(row[:revision_table].singularize)
            persistor.state_for_id(row[persistor.primary_key])
          end)
        end



        # Find all resources directly or indirectly modified
        # by a user session.
        def collect_related_states(user_session)
          # We start by finding the directly modified resources as seed
          # and follow their children and parents.
          # Normal persistor behavior can be overidden
          # by defining a specific persistor.

          seeds = collect_direct_states(user_session)
          Sequel::RevisionFinder::Session.new(@session.store, user_session.id).load_from_external_states(seeds, @session) do |finder_session|
            finder_session.object_states
          end
        end

        def revisions_for(user_session)
          @session.revision[{:session_id => user_session.id}, false]
        end
      end
    end
  end
end

