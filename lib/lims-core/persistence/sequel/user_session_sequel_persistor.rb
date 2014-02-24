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

        # Get the persistor corresponding to a table.
        # @param [String] Tab
        def self.persistor_for_table_name(table_name, session)
          debugger
          @table_name_to_persistor_class_map ||= build_table_name_to_persistor_map
          session.persistor_for(@table_name_to_persistor_class_map[table_name]::Model)
        end

        # Build the association map 'table_name' to persistor class
        # by iterating over all the persistors and inspecting their table name.
        def self.build_table_name_to_persistor_map
          map = {}
          Lims::Core::Resource.subclasses.each do |subclass|
            begin
              persistor_class = Sequel::Session.persistor_class_for(subclass)
              if persistor_class.respond_to? :table_name
                map[persistor_class.table_name.to_s] = persistor_class
              end
            rescue
            end
          end
          map
        end

        def collect_direct_states(user_session)
          StateList.new(@session.revision.dataset.filter(:session_id => user_session.id).map do |row|
              persistor_name = row[:revision_table]
              persistor = self.class.persistor_for_table_name(persistor_name, @session)
              persistor.state_for_id(row[persistor.primary_key]) if persistor
            end.compact)
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

