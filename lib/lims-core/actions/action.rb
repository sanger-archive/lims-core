require 'common'

require  'virtus'
require 'facets/ostruct'

module Lims::Core
  module Actions
    # This mixin add the Action behavior to a class.
    # An action can be called and reverted (if possible) within a {Persistence::Session session}.
    # For this, the action must implements the {Action::AfterEval#_call_in_session _call_in_session} and {Action::AfterEval#_revert_in_session _revert_in_session}.
    # Those methods are private and take a session as a parameter.
    # The public equivalent (call/revert) will create a session (using the store) and call the corresponding methods.

    module Action
      UnrevertableAction = Class.new(StandardError)
      def self.included(klass)
        klass.class_eval do
          include Virtus
          include Aequitas
          attribute :store, String, :required => true
          attribute :user, String, :required => true
          attribute :application, String, :required => true
          attribute :result, Object
          include AfterEval # hack so initialize would be called properly
        end
      end

      InvalidParameters = Class.new(RuntimeError)

      module AfterEval
        # Initialize a new actions
        # 'Common' parameters are set as argument
        # whereas specific ones are set on a dummy object via the block.
        # The block is executed within a session allowing to find object form id, etc.

        def initialize(*args, &initializer)
          @initializer = initializer
          super(*args)
        end

        # Executes the action.
        # This is a wrapper around _call_in_session,
        # and it shouldn't be overriden.
        # A block can be passed to  be evaluated with the session after the save session been saved.
        # This is usefull to get ids of saved object.
        # False will be returned if the action failed (or parameters are invalid)
        # @return the value return by the block
        # @yieldparam [Action] a self
        # @yieldparam [Session]  session the current session.
        def call(&after_save)
          after_save ||= lambda { |a,s| a.result }
          with_session do |s| 
            self.result = _call_in_session(s)

            _objects_to_save.each do |a| 
              s << a 
            end

            lambda { after_save[self, s] }
          end.andtap { |block| block.call }
        end

        # Execute the opposite of the action if possible.
        # This a wrapper around _revert_in_session,
        # and shouldn't be overriden.
        # @raise UnrevertableAction
        def revert()
          with_session { |s| _revert_in_session(s) }
        end

        # Execute the given block within a new session.
        # Validates the action and fill #errors if needed
        # @return [Object, False]
        def with_session(*args, &block)
          @store.with_session(*args) do |session|
            # initialize action
            if @initializer
              params = OpenStruct.new
              @initializer[params, session]
              set_attributes(params)
              @initializer = nil
            end

            block.call(session) if valid?
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

        # List of objects to save (add to the session).
        # By default get all attributes and the resulth.
        # Override if need (to add a created resource for example).
        # @return a list of object to save
        def _objects_to_save
          [result, *attributes.map { |a| a[1] }].select { |o| o.is_a?(Resource) }
        end
        private :_call_in_session, :_revert_in_session, :_objects_to_save
      end
    end
  end
end
