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
    end
  end
end

