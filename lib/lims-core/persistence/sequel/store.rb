# vi: ts=2:sts=2:et:sw=2

require 'lims-core/persistence/store'
require 'lims-core/persistence/sequel/session'
require 'sequel'

module Lims::Core
  module Persistence
    module Sequel
      # An Sequel::Store, ie an wrapper around a database
      # using the sequel gem
      class Store < Persistence::Store
        attr_reader :database
        # @attribute

        # Create a store with a Sequel::Database
        # We don't wrap for now the creation  of the database
        # @param [Sequel::Database] type underlying database
        def initialize(database, *args)
          raise RuntimeError unless database.is_a?(::Sequel::Database)
          @database = database
          super(*args)
          @dirty_attribute_strategy = DIRTY_ATTRIBUTE_STRATEGY_SHA1
        end

        # Execute given block within a transaction
        # and create a session object needed to update
        # revisionned table.
        def transaction
          database.transaction do
            if database.database_type == :sqlite
              super
            else

              user = "user"
              application = "application"
              session_id = database[:sessions].insert({:user => user, :application => application})
              database.run "SET @current_session_id = #{session_id}"

                super
              # mark it as finished
              database[:sessions].where(:id => session_id).update(:end_time => DateTime.now)
              database.run "SET @current_session_id = NULL"
            end
          end
        end
      end
    end
  end
end
