# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'common'

require 'lims-core/persistence'
require 'lims-core/persistence/session'

module Lims::Core
    module  Persistence
      # A store represents a persistent datastore, where object can be saved and restored.
      # A connection to a database, for example.
      class Store
        def self.const_missing(name)
          super(name)
        end

        # The dirty-attribute strategy decides
        # how object modification is detected
        # to avoid saved unmodified object.
        attr_accessor :dirty_attribute_strategy
        DIRTY_ATTRIBUTE_STRATEGY_DEEP_COPY = 1
        DIRTY_ATTRIBUTE_STRATEGY_SHA1 = 2
        DIRTY_ATTRIBUTE_STRATEGY_MD5 = 3

        # Retrieves the effective module of a class
        # Useful to call "sibling" classes.
        # @example
        #   class Sequel::Store < Store
        #     def session
        #        base_module::Session
        #   end
        #
        #   session will return a Sequel::Session instead of a ::Session.
        #
        # @return [Module]
        def self.base_module
          @base_module ||= begin
                            base_name = name.sub(/::\w+$/, '')
                            constant(base_name)
                          end
        end
        def base_module
          self.class.base_module
        end

        # Create a session and pass it to the block.
        # This is the only way to get a session.
        # @param [Array]
        # @yieldparam [Session] session the created session.
        # @return the value of the block
        def with_session(*params, &block)
          create_session(*params).with_session(&block)
        end


        # Create a session
        def create_session(*params)
          base_module::Session.new(self, *params)
        end

        # Execute given block within a transaction
        # If it make sense.
        def transaction
          yield
        end
      end
    end
end

