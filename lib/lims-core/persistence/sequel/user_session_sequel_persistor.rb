require 'lims-core/persistence/user_session_persistor'
require 'lims-core/persistence/sequel/persistor'

require 'lims-core/persistence/sequel/revision/session'
require 'lims-core/persistence/sequel/session_finder/session'


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


        def collect_user_session_states(objects)
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

        protected
        def session_ids_for_resource_state(resource_state)
        end
      end
    end
  end
end

