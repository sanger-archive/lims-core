require 'lims-core/persistence/sequel/persistor'
require 'lims-core/persistence/revision_persistor'

module Lims::Core
  module Persistence
    module Sequel
      module SessionFinder
        module Persistor
          def self.included(klass)
            klass.class_eval do
              include Sequel::Persistor
              include Persistence::Revision::UseRevisionTables
            end
          end

          def new_from_attributes(attributes)
            Persistence::Revision.new.tap do |revision|
              resource_id = attributes[:id]
              @session.session_ids << attributes.delete(:session_id)

              # we don't need to create the resource
              #revision.resource = super(attributes) if revision.action != 'delete'

              # create state so that children can be loaded from it.
              @id_to_state[resource_id]
            end
          end
        end
      end
    end
  end
end
