require 'lims-core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      module Revision
        module Persistor
          def self.included(klass)
            klass.class_eval do
              include Sequel::Persistor
            end
          end
        end
      end
    end
  end
end
