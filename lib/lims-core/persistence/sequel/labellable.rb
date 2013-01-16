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

        def save_raw_association(labellables_id, labels_id)
            dataset.insert(:labellables_id => labellables_id, :labels_id  => labels_id)
        end

        def filter_attributes_on_save(attributes, *params)
          attributes.delete(:content)
          attributes
        end

        # Mixin to be included by classes of Labellable::Labels
        class Label  < Persistence::Labellable::Label
          include Sequel::Persistor

          def self.table_name
            :labels
          end

          def load(labellable_id)
            dataset.filter(:labellable_id => labellable_id).each do |att|
              position = att.delete(:position)
              label =  Laboratory::Labellable::Label::new(att)
              yield(position, label)
            end
          end

          def filter_attributes_on_save(attributes, labellable_id, position)
            attributes.tap do
              attributes[:labellable_id]= labellable_id
              attributes[:position] = position
            end
          end
        end
      end
    end
  end
end
