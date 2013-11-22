module Lims::Core
  module Persistence
    module PersistorModule
      module BasePersistorModule

        # @param [String] model
        # @return [Bool]
        # Return true if the persistor module should extend the <model> persistor instance
        def self.defined_for?(model)
          true
        end

        # @param [StateGroup] states
        # @param [Array] params
        # Call each persistor modules which extend the persistor instance.
        # The called method is the method formed by the persistor module name
        # in snake case.
        # @example: PersistorModule::DoSomethingToThePersistor -> do_something_to_the_persistor
        def call_persistor_modules(states, *params)
          @session.persistor_module_map[Session.model_to_name(model)].map do |module_name|
            module_name.to_s.split("::").last.gsub(/(.)([A-Z])/, '\1_\2').downcase
          end.each do |method_name|
            self.send(method_name, states, *params) if self.respond_to?(method_name)
          end
        end
      end
    end
  end
end
