require 'lims-core/persistence/user_session_persistor'
require 'lims-core/persistence/sequel/persistor'


module Lims::Core
  module Persistence
    class UserSession
      class UserSessionSequelPersistor < UserSessionPersistor
        include Sequel::Persistor
        def self.table_name
          :sessions
        end
        def bulk_insert(*args, &block)
          raise Persistence::Session::ReadonlyClassException.new(UserSession)
        end
      end
    end
  end
end


