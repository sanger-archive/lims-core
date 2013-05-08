require 'bunny'
require 'common'

module Lims
  module Core
    module Persistence

      # Basic methods to publish messages on the bus
      # Use the bunny gem as RabbitMQ client
      class MessageBus

        include Virtus
        include Aequitas 
        attribute :connection_uri, String, :required => true, :writer => :private
        attribute :exchange_name, String, :required => true, :writer => :private
        attribute :durable, Boolean, :required => true, :writer => :private
        attribute :prefetch_number, Integer, :required => true, :writer => :private
        attribute :heart_beat, Integer, :required => false, :writer => :private

        # Exception ConnectionError raised after a failed connection
        # to RabbitMQ server.
        class ConnectionError < StandardError
        end 

        # Exception InvalidSettingsError raised after a setting error
        class InvalidSettingsError < StandardError
        end

        # Initialize the message bus and check the required options 
        # are passed as parameters.
        # @param [Hash] settings
        def initialize(settings = {})
          @heart_beat = settings["heart_beat"]
          @connection_uri = settings["url"]
          @exchange_name = settings["exchange_name"]
          @durable = settings["durable"]
          @prefetch_number = settings["prefetch_number"]
        end

        # Executed after a connection loss
        # The exception should be catched and rollback the actions.
        def connection_failure_handler
          Proc.new do
            raise ConnectionError, "can't connect to RabbitMQ server"
          end
        end

        # Create a new connection to the broker using
        # the connection settings.
        # Create a channel and setup a new exchange.
        def connect
          begin
            if valid?
              options = @heart_beat ? { :heartbeat => heart_beat } : {}
              @connection = Bunny.new(connection_uri, options)
              @connection.start
              @channel = @connection.create_channel
              set_prefetch_number(prefetch_number)
              set_exchange(exchange_name, :durable => durable)
            else
              raise InvalidSettingsError, "settings are invalid"
            end
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
          raise ConnectionError, "exchange is not reachable" unless @exchange.instance_of?(Bunny::Exchange)
          
          options.merge!(:persistent => @message_persistence) unless @message_persistence.nil? 
          @exchange.publish(message, options)
        end
      end
    end
  end 
end
