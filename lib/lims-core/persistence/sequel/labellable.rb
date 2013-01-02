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

#        def save_raw_association(labellables_id, labels_id)
#            dataset.insert(:labellables_id => labellables_id, :labels_id  => labels_id)
#        end

        def filter_attributes_on_save(attributes, *params)
          attributes.delete(:content)
          attributes
        end

        class Label < Persistence::Labellable::Label
          include Sequel::Persistor

          def self.table_name
            :labels
          end

          def loads(labellable_id)
            dataset.filter(:labellable_id => labellable_id).each do |att|
              position = att.delete(:position)
              label = @session.labellable.content.get_or_create_single_model(att[:id], att)
              yield(position, label)
            end
          end
        end
      end
    end
  end
end
