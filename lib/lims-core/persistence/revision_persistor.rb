require 'common'

require 'lims-core/persistence/persistable_trait'
require 'lims-core/persistence/session'
require 'lims-core/persistence/revision'

module Lims::Core
  module Persistence
    class Revision

      (does 'lims/core/persistence/persistable').class_eval do
        def bulk_insert(*args, &block)
          raise Session::ReadonlyClassException(UserSession)
        end

        def keep_primary_key?
          true
        end
      end
    end
  end
end

