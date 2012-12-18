require 'lims/core/persistence/labellable'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      class Labellable < Persistence::Labellable
        include Sequel::Persistor

        def self.table_name
          :labellables
        end

        class Label < Persistence::Labellable::Label
          include Sequel::Persistor

          def self.table_name
            :labels
          end

          def loads(labellable_id)
            dataset.filter(:labellable_id => labellable_id).each do |att|
              debugger
              label = @session.labellable.label.get_or_create_single_model(att[:id], att)
              yield(label)
            end
          end
        end
      end
    end
  end
end
