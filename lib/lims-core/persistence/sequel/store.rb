# vi: ts=2:sts=2:et:sw=2

require 'lims/core/persistence/store'
require 'lims/core/persistence/sequel/session'

module Lims::Core
  module Persistence
    module Sequel
      # An Sequel::Store, ie an wrapper around a database
      # using the sequel gem
      class Store < Persistence::Store
        attr_reader :database

        # Create a store with a Sequel::Database
        # We don't wrap for now the creation  of the database
        # @param [Sequel::Database] type underlying database
        def initialize(database, *args)
          raise RuntimeError unless database.is_a?(::Sequel::Database)
          @database = database
          super(*args)
        end
      end
    end
  end
end
