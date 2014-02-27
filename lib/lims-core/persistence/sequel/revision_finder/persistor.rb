require 'lims-core/persistence/sequel/revision/persistor'

module Lims::Core
  module Persistence
    module Sequel
      module RevisionFinder
        module Persistor
          def self.included(klass)
            klass.class_eval do
              include Revision::Persistor
              include InstanceMethods
              def self.table_name
                return super
              end
            end
          end
          
          module InstanceMethods
            def parents_for_attributes(attributes)
              dependencies_for_attributes(attributes)
            end

            def load_children(states, *params)
              load_dependencies(states, *params)
            end

            def new_from_attributes(attributes)
              Persistence::Revision.new.tap do |revision|
                revision.model = model
                revision.action = attributes.delete(:action)
                revision.number = attributes.delete(:revision)
                revision.id = attributes[:id]
                revision.session_id = attributes.delete(:session_id)

                # associate the revision to the ResourceState
                state =  @id_to_state[revision.id]
                @session.manage_state(state)
                state.revision = revision
              end
            end
          end
        end
      end
    end
  end
end
