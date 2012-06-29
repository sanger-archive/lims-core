# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'common'

require 'lims/core/persistence/persistor'
require 'lims/core/uuids/uuid_resource'

module Lims::Core
  module  Persistence
    class UuidResource < Persistor
      Model = Uuids::UuidResource

      def filter_attributes_on_save(attributes)
        attributes.mash do |k,v|
          case k
          when :model_class then   [ k, @session.model_name_for(v) ]
          when :uuid then [ k, Uuids::UuidResource.pack(v) ]
          else [k, v]
          end
        end
      end

      def filter_attributes_on_load(attributes)
        attributes.mash do |k,v|
          case k
          when :model_class then [ k, @session.class_for(v) ]
          when :uuid then [ k, Uuids::UuidResource.unpack(v) ]
          else [k, v]
          end
        end
      end
    end
  end
end

