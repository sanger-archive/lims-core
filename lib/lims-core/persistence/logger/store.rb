# vi: ts=2:sts=2:et:sw=2

require 'logger'
require 'lims-core/persistence'
require 'lims-core/persistence/store'
require 'lims-core/persistence/logger/session'
require 'lims-core/persistence/logger/persistor'

module Lims::Core
  module Persistence
    module Logger
      # An Logger::Store, a store 'logging' object instead of 
      # saving them.
      class Store < Persistence::Store
        attr_reader :logger
        attr_reader :method

        # Create a store with an underlying logger.
        # @param [Logger, file] logger 
        # @param [Symbol, String] method the method call to
        # send information to the logger.
        def initialize(logger, method=:info, *args)
          @logger = case logger
                    when ::Logger then  logger
                    else ::Logger.new(logger)
                    end
          @method = method
          super(*args)
        end

        def log(msg)
          @logger.send(@method, msg)
        end
      end
    end
  end
end
