require 'common'

require  'virtus'

module Lims::Core
  module Actions
    # This mixin add the Action behavior to a class.
    # An action can be called and reverted (if possible) within a {Persistence::Session session}.
    # For this, the action must implements the {call_in_session} and {revert_in_session}.
    # Those methods are private and take a session as a parameter.
    # The public equivalent (call/revert) will create a session (using the store) and call the corresponding methods.

    module Action
      UnrevertableAction = Class.new(StandardError)
      def self.included(klass)
        klass.class_eval do
          include Virtus
          attribute :store, String, :required => true
          attribute :user, String, :required => true
          attribute :application, String, :required => true
          attribute :name, String, :required => true, :writer => :private
        end

        # Execute the action.
        # This is a wrapper around _call_in_session,
        # and it shouldn't be overriden.
        def call()
          with_session { |s| _call_in_session(s) }
        end

        # Execute the opposite of the action if possible.
        # This a wrapper around _revert_in_session,
        # and shouldn't be overriden.
        # @raise UnrevertableAction
        def revert()
          with_session { |s| _revert_in_session(s) }
        end

        def with_session(*args, &block)
          @store.with_session(*args, &block)
        end

        # This is the main method of an action,
        # called to effectively perform an action.
        def _call_in_session(session)
          raise NotImplementedError
        end

        # how to revert the action,
        # if possible.
        def _revert_in_session(session)
          raise UnrevertableAction(self)
        end
        private :_call_in_session, :_revert_in_session
      end
    end
  end
end
