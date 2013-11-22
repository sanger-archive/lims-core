module Lims::Core
  module Persistence
    module BasePersistorModule
      def self.included(klass)
        klass.class_eval do
          def defined_for?(persistor_class)
            false
          end
        end
      end

      def call_persistor_module(*params, &block)

      end
    end

    module BasePersistorModule

    end
  end
end
