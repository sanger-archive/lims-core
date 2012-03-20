# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


#require 'lims/core/persistance/session'
require 'common'

module Lims::Core
    module  Persistance
      # A store represents a persistant datastore, where object can be saved and restored.
      # A connection to a database, for example.
      class Store
        def self.const_missing(name)
          super(name)
        end

        # Retrieves the effective module of a class
        # Useful to call "sibling" classes.
        # @example
        # class Sequel::Store < Store
        #   def session
        #      base_module::Session
        # end
        #
        # session will return a Sequel::Session instead of a ::Session.
        #
        # @returns [Module]
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
      end
    end
end

