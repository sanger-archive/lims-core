require 'lims/core/persistence/labellable'
require 'lims/core/persistence/sequel/persistor'

require 'lims/core/uuids/uuid_resource'

module Lims::Core
  module Persistence
    module Sequel
      class Labellable < Persistence::Labellable
        include Sequel::Persistor

        def self.table_name
          :labellables
        end

      # Pack if needed an uuid to its store representation
      # @param [String] uuid
      # @return [Object]
      def self.pack_uuid(uuid)
        Uuids::UuidResource::pack(uuid)
      end

      # Unpac if needed an uuid from its store representation
      # @param [Object] puuid
      # @return [String]
      def self.unpack_uuid(puuid)
        Uuids::UuidResource::unpack(puuid)
      end

        def save_raw_association(labellables_id, labels_id)
            dataset.insert(:labellables_id => labellables_id, :labels_id  => labels_id)
        end

        def filter_attributes_on_save(attributes, *params)
          attributes.delete(:content)
          if attributes[:type] == "resource"
            name = attributes[:name]
            attributes[:name] = pack_uuid(name)
          end
          attributes
        end

        def filter_attributes_on_load(attributes, *params)
          if attributes[:type] == "resource"
            name = attributes[:name]
            attributes[:name] = unpack_uuid(name)
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
