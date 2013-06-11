require 'lims-core/actions/action_group'

module Lims::Core
  module Actions
    # *Lift* an action to a bulk one
    # by creating a group of similar actions.
    # The parameters being a array of parameters which will
    # be used to create each individual action.
    module BulkAction
      def self.included(klass) 
        klass.instance_eval  do
          # @param [String] element_name name of the underlying action. Use to get the result from the subaction element.
          # @param [String] parameters key to get parameters array for each action and return the result.
          def initialize_class(element_name, group_name, action_class)
            define_method :group_name do
              group_name
            end

            define_method :action_class do
              action_class
            end

            define_method :element_name do
              element_name
            end

            self.class_eval do
              include ActionGroup
              attribute group_name, Array, :required => true
              include AfterEval
            end
          end
        end
      end

      module AfterEval

        def initialize(*args, &initializer)
          super(*args) do |a,s|
            initializer.call(a,s) if initializer
            parameter_list = a[group_name]
            debugger
            a.actions = parameter_list.map do |parameters|
              action_class.new do |action, session|
                  # We copy the parameters to action class.
                  # action, is not the real action but an open struct.
                  # We can't just pass the parameters in the constructor
                  # in case some parameters are private.
                  parameters.each { |k, v| action[k] = v }
              end
            end
          end
        end

        def _call_in_session(session)
          super(session)
            {group_name=> actions.map { |a| a.result[element_name] }}
        end
      end
    end
  end
end
