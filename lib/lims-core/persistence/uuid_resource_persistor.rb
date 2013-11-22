# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'common'

require 'lims-core/persistence/persistor'
require 'lims-core/persistence/uuid_resource'

module Lims::Core
  module  Persistence
    class UuidResource
      class UuidResourcePersistor < Persistence::Persistor
        Model = UuidResource

        def parents_for(resource)
          resource.state && resource.state.resource ? [resource.state] : []
        end

        def filter_attributes_on_save(attributes)
          attributes.mash do |k,v|
            case k
            when :model_class then   [ k, @session.model_name_for(v) ]
            when :uuid then [ k, @session.pack_uuid(v) ]
            when :state
              [:key, v && v.id]
            else [k, v]
            end
          end
        end

        def filter_attributes_on_load(attributes)
          attributes.mash do |k,v|
            case k
            when :model_class then [ k, @session.class_for(v) ]
            when :uuid then [ k, @session.unpack_uuid(v) ]
            when :key then [:state, @session.persistor_for(attributes[:model_class]).state_for_id(attributes[:key])]
            else [k, v]
            end
          end
        end
      end
    end
  end
end

