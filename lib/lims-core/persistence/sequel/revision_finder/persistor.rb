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
          end
        end
      end
    end
  end
end
