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

          finder_session = Sequel::SessionFinder::Session.new(@session.store)
          resource_states = StateList.new(objects.map do |object|
              case object
              when ResourceState then object.new_for_session(finder_session)
              when Resource then @session.state_for(object).new_for_session(finder_session)
              end
            end
          )

          resource_states.load

          finder_session.session_ids.to_a.sort

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

          debugger
          seeds = collect_direct_states(user_session)
          user_session.with_session do |finder_session|
          resource_states = StateList.new(seeds.map do |object|
              case object
              when ResourceState then object.new_for_session(finder_session)
              when Resource then @session.state_for(object).new_for_session(finder_session)
              end
            end
          )

          # Reload all the seeds withint the new RevisionFinder::Session.
          # This should load all related resources.
         
          resource_states.load
          debugger

          finder_session.instance_eval { @object_states }
        end
        end

        def revisions_for(user_session)
          debugger
          @session.revision[{:session_id => user_session.id}, false]
        end
      end
    end
  end
end

