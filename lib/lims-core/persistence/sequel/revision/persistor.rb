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
              include InstanceMethods
              def self.table_name
                :"#{super}_revision"
              end
            end
          end
          module InstanceMethods

            def session_id
              @session.session_id
            end

            def create_resource_state(resource, id=nil)
              self.class::ResourceState.new(resource, self, id)
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

            def new_from_attributes(attributes)
              Persistence::Revision.new.tap do |revision|
                revision.model = model
                revision.action = attributes.delete(:action)
                revision.number = attributes.delete(:revision)
                revision.id = attributes[:id]
                revision.session_id = attributes.delete(:session_id)

                revision.resource = super(attributes) if revision.action != 'delete'

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
