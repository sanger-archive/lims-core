require 'lims-core/actions/action'

module Lims::Core
  module Actions
    # This module provide a helper to execute multiple action a time.
    # This module is not intended to be used as a bare class but more
    # as a base to define multiple actions "creator", which will
    # manage the needed parameters and create the actions consequently.
    # This action executes all the action in sequence and the result
    # is an array of the results.
    module ActionGroup
      def self.included(klass)
        klass.class_eval do 
          include Action
          include AfterEval
          attribute :actions, Array, :required => true, :writer => :private , :reader => :private, :initializable => true
        end

      end

      # This module is needed
      # otherwire the following methogs
      # will be overriden by the mixin called in self.included.
      module AfterEval

        # We need to override call to process all the after_save
        # once all actions have been executed
        def execute_and_store_result(session, &after_save)
          after_save ||= lambda { |a,s| a.result }
          self.result = _call_in_session(session)
          lambda { after_save[self, session] }
        end

        def _call_in_session(session)
          actions.map do |action|
            update_action_attribute(action)
            action.with_session(session) do |new_session|
              action.execute_and_store_result(new_session)
              action.result
            end
          end
        end

        # Set the required attribute of the children action
        # to the parent one.
        def update_action_attribute(action)
          %w(store user application).each do |attribute|
            action[attribute]=self[attribute]
          end
        end
      end
    end
  end
end
