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

        # Initialize the message bus and check the required options 
        # are passed as parameters.
        # @param [Hash] bus settings
        def initialize(bus_settings = {})
          %w{host port exchange_name durable prefetch_number}.each do |setting|
            raise MessageBusError, "#{setting} option is required to use the message bus" unless bus_settings.include?(setting.to_s)
          end
          @config = bus_settings
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
        # Create a channel and setup a new exchange.
        def connect
          begin
            @connection = Bunny.new(:host => @config["host"], :port => @config["port"])
            @connection.start
            @channel = @connection.create_channel
            set_prefetch_number(@config["prefetch_number"])
            set_exchange(@config["exchange_name"], :durable => @config["durable"])
          rescue Bunny::TCPConnectionFailed, Bunny::PossibleAuthenticationFailureError => e
            connection_failure_handler.call
          end
        end  

        # Close the connection
        def close
          @connection.close 
        end

        # Create (or get if it already exists) a new topic
        # exchange with the given options.
        # Especially, the durable option can be set here to
        # mark the exchange as durable (survive a server restart)
        # @param [String] name
        # @param [Hash] exchange options
        def set_exchange(exchange_name, options = {})
          @exchange = @channel.topic(exchange_name, options)
        end
        private :set_exchange

        # Specifies the number of messages to prefetch.
        # @param [int] number of messages to prefetch
        def set_prefetch_number(number)
          @channel.prefetch(number)
        end
        private :set_prefetch_number

        # Set the message persistence behaviour.
        # If persistent, the message will be persisted to disk
        # and remain in the queue until it is consumed. 
        # Survive a server restart.
        # BUNNY ISSUE: bunny0.9pre4 hardcodes the persistent option. 
        # @see lib/bunny/channel.rb:174 :delivery_mode => 2
        # It is set all the time, meaning the messages will survive 
        # a server restart, if the queue and the exchange are durable.
        # @param [Bool] persistence
        def set_message_persistence(persistent)
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
