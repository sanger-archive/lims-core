# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'sequel'
require 'lims-core/persistence'

module Lims::Core
  module Persistence
    # Add uuid behavior (lookup and creation) to a Session
    module Uuidable
      # lookup one or more objects  by uuid or resource_uuid
      # @param [String, Arrary<String>, UUidResource] args 
      # @return [Resource, nil, Array<Resource>]
      def [](args)
        case args
        when Uuids::UuidResource then for_uuid_resource(args)
        when String then for_uuid(args)
        when Array then for_uuids(args)
        else
          super(args)
        end
      end

      # Retrieve  id from an object or a Hash with a uuid key
      # A list of uuids will 
      def id_for(object)
        case object
        when Array
          object.map { |o| id_for(o) }
        when Hash
          id_for(object[:uuid] || object["uuid"])
        when String 
          # We assume it is an uuid
          self.uuid_resource[:uuid => pack_uuid(object)].andtap {  |ur| ur.key }
        else
          super
        end
      end
      # Compute the name (string) used to be saved in the Uuid table.
      # @param [Class] model_class class of the resource
      # @return [String]
      def model_name_for(model_class)
        persistor_name_for(model_class)
      end

      # Get the class from the class name. Inverse of {#model_name_for}.
      def class_for(model_name)
        persistor_for(model_name).model
      end

      def new_uuid_resource_for(object)
        object_id =  id_for(object)
        key  = object_id ? object_id : lambda { self.id_for(object) }
        Uuids::UuidResource.new(:key => key, :model_class => object.class).tap do |r|
          self << r
        end
      end

      def uuid_resource_for(object)
        self.uuid_resource[:key => id_for(object), :model_class => model_name_for(object.class)]
      end

      # Finds the uuid of an object if it exists
      def uuid_for(object)
        # We need to check if the object is managed and have alreday an id
        raise RuntimeError, "Unmanaged object" unless managed?(object)
        id_for(object) && uuid_resource_for(object).andtap { |r|  r.uuid }
      end


      # Find or create a uuid for an object
      def uuid_for!(object)
        uuid_for(object) || new_uuid_resource_for(object).uuid
      end

      # Delete the underlying resource of a UuidResource
      # @param [UuidResource] uuid_resource
      # @return [Id, nil] 
      def delete_resource(uuid_resource)
        delete(for_uuid_resource(uuid_resource))
        uuid_resource.key
      end


      protected
      # find/load the object referenced by a uuid resource.
      # Don't need to be called explicitely. use session[resource_uuid] instead
      # @param [UuidResource] uuid_resource
      # @return [Resource]
      def for_uuid_resource(uuid_resource)
          persistor_for(uuid_resource.model_class)[uuid_resource.key]
      end

      def for_uuid(uuid)
        self.uuid_resource[:uuid => uuid].andtap do |r|
          for_uuid_resource(r)
        end
      end

      # @todo bulk load
      def for_uuids(uuids)
        uuids.map { |u| for_uuid(u) }.compact
      end
    end
  end
end
