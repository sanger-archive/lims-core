require 'lims-core/persistence/sequel/persistor'
require 'lims-core/persistence/revision'

module Lims::Core
  module Persistence
    module Sequel
      module Revision
        module Persistor
          class ResourceState < Persistence::ResourceState
            attribute :revision, Persistence::Revision
          end
          def self.included(klass)
            klass.class_eval do
              include Sequel::Persistor
              include Persistence::Revision::UseRevisionTables
              include InstanceMethods
              include Persistence::Revision::UseRevisionTables
            end
          end
          module InstanceMethods

            def session_id
              @session.session_id
            end

            def create_resource_state(resource, id=nil)
              self.class::ResourceState.new(resource, self, id)
            end

            def ids_for(criteria)
              # First we need to get all the ids of the objects which matched the criteria at some point
              # in the past
              matching_ids = dataset.select(qualified_key).filter(criteria).filter(:session_id => 1..session_id)

              # We need to get the latest version of thoses object
              #
              ids_and_sessions = dataset.select_group(qualified_key).select_more{
                ::Sequel.as(max(:session_id), :session_id)
              }.join(matching_ids,
                :id => :id,
              ).filter(:session_id => 1..session_id)


              # Load object id if the last state matches the criteria
              d = dataset.select(qualified_key, :action, qualify(:session_id) ).join(ids_and_sessions, {
                :id => :id,
                :session_id => :session_id
              }
              ).filter(criteria)
              # However we are not interested in deleted object except if they match the 
              # current session. If they don't, they don't exist in the current database state.
              # We do the filter in ruby, as it seems impossible to write it using Sequel.
              # Problem encountered within a virtual block is either
              # columnn are  non qualified or local variable seen as column.
              d.map.select { |h| h[:session_id] == session_id || h[:action] != "delete"}.map { |h| h[primary_key] }
            end


            def find_ids_from_internal_ids(internal_ids)
              dataset.select_group(primary_key).
              select_more{::Sequel.as(max(:session_id), :session_id)}.filter(primary_key => internal_ids.map(&:id), :session_id => 1..session_id )
            end

            def  bulk_load(ids, *params, &block)
              internal_ids_set = find_ids_from_internal_ids(ids)
              dataset.join(internal_ids_set,
                :id => :id,
                :session_id => :session_id
              ).all(&block)
            end

            def load_resource?(revision)
              revision.action != 'delete'
            end

            def new_from_attributes(attributes)
              Persistence::Revision.new.tap do |revision|
                revision.model = model
                revision.action = attributes.delete(:action)
                revision.number = attributes.delete(:revision)
                revision.id = attributes[:id]
                revision.session_id = attributes.delete(:session_id)

                revision.state = super(attributes) if load_resource?(revision)

                # associate the revision to the ResourceState
                state =  @id_to_state[revision.id]
                state.revision = revision
              end
            end
          end

          def revision_for(id)
            state_for_id(id).revision
          end
        end
      end
    end
  end
end
