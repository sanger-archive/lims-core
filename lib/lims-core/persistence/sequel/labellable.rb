require 'lims/core/persistence/labellable'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      class Labellable < Persistence::Labellable
        include Sequel::Persistor

        def self.table_name
          :labellables
        end

#        class Content < Persistence::Labellable::Content
#          include Sequel::Persistor
#          
#          def self.table_name
#            :contents
#          end
#        end
      end
    end
  end
end
