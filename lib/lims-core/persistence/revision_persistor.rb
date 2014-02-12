require 'common'

require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/session'
require 'lims-core/persistence/revision'

module Lims::Core
  module Persistence
    class Revision

      (does 'lims/core/persistence/persistable').class_eval do
        include Persistor::ReadOnly
        def keep_primary_key?
          true
        end
      end

      module UseRevisionTables

        def self.included(klass)
          klass.instance_eval do
            def table_name
              :"#{super}_revision"
            end
          end
        end
      end
    end
  end
end

