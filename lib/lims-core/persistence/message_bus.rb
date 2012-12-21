require 'bunny'

module Lims
  module Core
  module Persistence

    # Exception MessageBusError raised after a failed connection
    # to RabbitMQ server.
    class MessageBusError < StandardError
    end 

    # Basic methods to publish messages on the bus
    # Use the bunny gem as RabbitMQ client
    class MessageBus

      def initialize(connection_settings = {})
        @connection_settings = connection_settings
      end

      # Executed after a connection loss
      # The exception should be catched and rollback the actions.
      def connection_failure_handler
        Proc.new do
          raise MessageBusError, "can't connect to RabbitMQ server"
        end
      end

      # Create a new connection to the broker using
      # the connection settings.
      def connect
        begin
          @connection = Bunny.new(@connection_settings)
          @connection.start
        rescue Bunny::TCPConnectionFailed, Bunny::PossibleAuthenticationFailureError => e
          connection_failure_handler.call
        end
      end  

      def close
        @connection.close 
      end

      def create_channel
        @channel = @connection.create_channel 
      end

      def topic(name, options = {})
        @exchange = @channel.topic(name, options)
      end

      def publish(message, options = {})
        @exchange.publish(message, options)
      end
    end
  end
end 
end
