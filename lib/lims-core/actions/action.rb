require 'common'

require  'virtus'
require 'facets/ostruct'

require 'lims-core/persistence/store'

module Lims::Core
  module Actions
    # This mixin add the Action behavior to a Class.
    # An action can be called and reverted (if possible) within a {Persistence::Session session}.
    # For this, the action must implements the {Action::AfterEval#_call_in_session _call_in_session} and {Action::AfterEval#_revert_in_session _revert_in_session}.
    # Those methods are private and take a session as a parameter.
    # The public equivalent (call/revert) will create a session (using the store) and call the corresponding methods.

    module Action
      extend SubclassTracker
    class << self
      alias_method :tracker_included, :included
    end
      UnrevertableAction = Class.new(StandardError)
      def self.included(klass)
        klass.class_eval do
          include Base
          attribute :store, Persistence::Store, :required => true
          attribute :user, Object, :required => true, :writer => :private, :initializable => true
          attribute :application, String, :required => true
          attribute :result, Object
          include AfterEval # hack so initialize would be called properly
        end
        tracker_included(klass)
      end

      class InvalidParameters < RuntimeError
        attr_reader :errors
        def initialize(errors = {})
          @errors = errors
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
          with_session do |session| 
            execute_and_store_result(session, &after_save)
          end.andtap { |block| block.call }
        end

        def execute_and_store_result(session, &after_save)
          after_save ||= lambda { |a,s| a.result }
          self.result = _call_in_session(session)
          _objects_to_save.each do |a| 
            session << a 
          end
          lambda { after_save[self, session] }
        end

        protected :execute_and_store_result

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

              # We want to catch ALL attributes errors
              # therefore We need to iterate on each attributes
              # and catch the potentiel exception raised by each
              # assignment.


              attribute_errors = []
              params.each do |key, value|
                next if %w(user application_id).include?(key.to_s)
                begin
                  send("#{key}=", value)
                rescue NoMethodError => e
                  attribute_errors << [key, value]
                end
              end  

              unless attribute_errors.empty?
                # An error occured.
                # We need to check if set attributes are valid
                # and add the attributes errors to the general error message.
                valid?
                invalid_parameters = errors_to_hash

                attribute_errors.each do |key, value|
                  invalid_parameters[key] = ["field :#{key} doesn't exist or value '#{value}' is invalid"]
                end
                raise InvalidParameters.new(invalid_parameters)
              end
              @initializer = nil
            end

            # Note: there is a bug in Aequitas gem on the valid?
            # method call. For an attribute which needs to be required
            # and greater than 0, the greater than 0 is tested first
            # and the required after. So if the parameter is not set, 
            # nil >= 0 is evaluated by Aequitas and an exception is 
            # raised. We catch it here and raise an InvalidParameters error.
            is_valid = begin 
            valid?
            rescue
              raise InvalidParameters.new
            end

            if is_valid
              block.call(session)
            else
              invalid_parameters = errors_to_hash
              raise InvalidParameters.new(invalid_parameters)
            end
          end
        end

        def errors_to_hash()
          {}.tap do |hash|
            errors.keys.each do |key|
              hash[key] = [].tap do |array|
                # errors[key] returns an array of Aequitas::Violation
                errors[key].each do |error|
                  array << error.message
                end
              end
            end
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
