require 'lims-core/labels/labellable/labellable_persistor'
require 'lims-core/persistence/sequel/persistor'

require 'lims-core/persistence/uuid_resource'

module Lims::Core
  module Labels
    class Labellable::LabellableSequelPersistor < LabellablePersistor
      include Sequel::Persistor

      def self.table_name
        :labellables
      end


      def save_raw_association(labellables_id, labels_id)
          dataset.insert(:labellables_id => labellables_id, :labels_id  => labels_id)
      end

      def filter_attributes_on_save(attributes, *params)
        attributes.delete(:content)
        if attributes[:type] == "resource"
          name = attributes[:name]
          attributes[:name] = @session.pack_uuid(name)
        end
        attributes
      end

      def filter_attributes_on_load(attributes, *params)
        if attributes[:type] == "resource"
          name = attributes[:name]
          attributes[:name] = @session.unpack_uuid(name)
        end
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
              label =  Labels::Labellable::Label::new(att)
              yield(position, label)
            end
          end

          def filter_attributes_on_save(attributes, labellable_id=nil, position=nil)
            attributes.tap do
              attributes[:labellable_id]= labellable_id if labellable_id
              attributes[:position] = position if position
            end
          end
        end
      end
    end
  end
