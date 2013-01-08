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

        # Create a new topic exchange with the given options
        # Especially, the durable option can be set here to
        # mark the exchange as durable (survive a server restart)
        # @param [String] name
        # @param [Hash] exchange options
        def topic(name, options = {})
          @exchange = @channel.topic(name, options)
        end

        # Specifies the number of messages to prefetch.
        # @param [int] number of messages to prefetch
        def prefetch(number)
          @channel.prefetch(number)
        end

        # Set the message persistence behaviour.
        # If persistent, the message will be persisted to disk
        # and remain in the queue until it is consumed. 
        # Survive a server restart.
        # BUNNY ISSUE: bunny0.9pre4 hardcodes the persistent option. 
        # @see lib/bunny/channel.rb:174 :delivery_mode => 2
        # It is set all the time, meaning the messages will survive 
        # a server restart, if the queue and the exchange are durable.
        # @param [Bool] persistence
        def message_persistence(persistent)
          @message_persistence = persistent 
        end

        # Publish a message on the bus with the given options
        # The routing key is passed in the options.
        # @param [String] JSON message
        # @param [Hash] publishing options
        def publish(message, options = {})
          options.merge!(:persistent => @message_persistence) unless @message_persistence.nil? 
          @exchange.publish(message, options)
        end
      end
    end
  end 
end
