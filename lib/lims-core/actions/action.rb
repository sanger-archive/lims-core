require 'common'

require  'virtus'
require 'facets/ostruct'

module Lims::Core
  module Actions
    # This mixin add the Action behavior to a class.
    # An action can be called and reverted (if possible) within a {Persistence::Session session}.
    # For this, the action must implements the {call_in_session} and {revert_in_session}.
    # Those methods are private and take a session as a parameter.
    # The public equivalent (call/revert) will create a session (using the store) and call the corresponding methods.

    module Action
      UnrevertableAction = Class.new(StandardError)
      InvalidParameters = Class.new(RuntimeError)
      def self.included(klass)
        klass.class_eval do
          include Virtus
          attribute :store, String, :required => true
          attribute :user, String, :required => true
          attribute :application, String, :required => true
          attribute :result, Object
          include AfterEval # hack so initialize would be called properly
        end
      end

      module AfterEval
        # Initialize a new actions
        # 'Common' parameters are set as argument
        # whereas specific ones are set on a dummy object via the block.
        # The block is executed within a session allowing to find object form id, etc.

        def initialize(*args, &initializer)
          @initializer = initializer
          super(*args)
        end

        # Execute the action.
        # This is a wrapper around _call_in_session,
        # and it shouldn't be overriden.
        # A block can be passed to  be evaluated with the session after the save session been saved.
        # This is usefull to get ids of saved object.
        # @return the value return by the block
        # @yield_param [Action] a self
        # @yield_param [Session]  session the current session.
        def call(&after_save)
          after_save ||= lambda { |a,s| a.result }
          with_session do |s| 
            self.result = _call_in_session(s)
            lambda { after_save[self, s] }
          end.call
        end

        # Execute the opposite of the action if possible.
        # This a wrapper around _revert_in_session,
        # and shouldn't be overriden.
        # @raise UnrevertableAction
        def revert()
          with_session { |s| _revert_in_session(s) }
        end

        def with_session(*args, &block)
          @store.with_session(*args) do |session|
            # initialize action
            if @initializer
              params = OpenStruct.new
              @initializer[params, session]
              set_attributes(params)
              @initializer = nil
            end

            _validate_parameters()
            block.call(session)
          end
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

        # To be overriden
        # @raise  [InvalidParameters] if needed
        def _validate_parameters()
        end
        private :_call_in_session, :_revert_in_session
      end
    end
  end
end
