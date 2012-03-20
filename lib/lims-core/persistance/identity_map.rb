# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'common'

module Lims::Core
  module Persistance
    # Mixing giving  an identity map behavior
    # ie a map (both way) between id and object
    module IdentityMap
      # Raised if there is any duplicate in the identity map 
      class DuplicateError < RuntimeError 
      end

      #Raised if the `id` is already associated to a different `object`
      class DuplicateIdError <DuplicateError
      end

      #Raised if the `object` is already associated to a different `id`
      class DuplicateObjectError < DuplicateError
      end

      # Look for the id associated to an object and yield it to the block
      # if found.
      def id_for(object, &block)
        @object_to_id[object].andtap(&block)
      end

      # Look for the object associated to an object and yield it to the block
      # if found.
      def object_for(id, &block)
        @id_to_object[id].andtap(&block)
      end

      # bound an id to an object
      def map_id_object(id, object)
        return nil unless id && object
        raise DuplicateIdError, id unless @id_to_object.fetch(id, object).equal? object
        raise DuplicateObjectError, object unless  @object_to_id.fetch(object, id).equal? id
        @id_to_object[id] = object
        @object_to_id[object] = id
      end

      def initialize(*args, &block)
        super(*args, &block)
        @id_to_object = {}
        @object_to_id = {}
      end
    end
  end
end
