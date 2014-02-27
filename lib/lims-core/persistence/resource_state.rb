# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'virtus'

require 'lims-core/resource'
require 'lims-core/persistence/persistor'

module Lims::Core
  module Persistence
    # Hold different information relateed particular resource
    # within a {Session}/{Persistor}.
    # This could be the database id, the current saving state etc ...
    class ResourceState
      include Virtus
      attribute :id, Object
      attribute :uuid_resource, Object
      attribute :resource, Object, :writer => :private, :required => true
      attribute :persistor, Persistor, :writer => :private, :required => true
      attribute :to_delete, Object, :writer => :private

      def children_saved?
        @children_saved
      end

      def body_saved?
        @body_saved
      end

      def initialize(resource, persistor, id=nil)
        @resource=resource
        @persistor=persistor
        self.id=id if id
        @to_delete = false
        update_dirty_key
        reset

      end

      def to_delete
        @to_delete
      end


      def id
        @id
      end

      def resource
        @resource
      end

      def persistor
        @persistor
      end

      def dirty_key
        @persistor.dirty_key_for(resource)
      end

      def update_dirty_key
        @last_dirty_key = resource ?  @persistor.dirty_key_for(resource) : nil
      end

      def new?
        @id == nil
      end

      def to_load?
        (@id != nil && @resource == nil && !@loading)
      end

      # To avoid loading the same object recursively
      # if its parents are loading it.
      def to_load!
        to_load?.tap do
          @loading = true
        end
      end



      def dirty?
       !@body_saved && dirty_key != @last_dirty_key
      end

      def id=(new_id)
        return  if new_id == @id
        raise RuntimeError, "modifing existing id not allowed. #{self}"   if @id
        @id = new_id
        # link the new id in th id_to_state map
        @persistor.bind_state_to_id(self)
        id
      end

      def resource=(new_resource)
        # Hack
        # for some emtpy resources , resource == nil returns true
        # but nil == resource returns false
        # which is why we test both.
        return if resource == new_resource && new_resource == resource
        debugger if @resource
        #raise RuntimeError, "modifing existing resource not allowed. #{self}"   if @resource
        @resource = new_resource
        # link the new resource in th resource_to_state map
        @persistor.bind_state_to_resource(self)
        update_dirty_key
        resource
      end

      def mark_for_deletion
        @to_delete = true
      end

      # @todo use state machine ?
      def save_action
        case
        when @body_saved then nil
        when to_delete && !new? then :delete
        when new? then :insert
        when dirty? then :update
        end
      end

      def inserted(new_id=nil)
        self.id = new_id
        update_dirty_key
      end

      def updated
        update_dirty_key
      end

      def parents_saved!
        @parents_saved = true
      end
      def parents
        !@parents_saved && @persistor.parents_for(resource)
      end
      def parents!
        parents.tap { parents_saved! }
      end
      def children_saved!
        @children_saved = true
      end

      def parents_saved?
        @parents_saved
      end
      def children
        return [] if to_delete
        !@children_saved && @persistor.children_for(resource)
      end
      def children!
        children.tap { children_saved! }
      end
      def body_saved!
        @body_saved = true
      end

      def reset
        @parents_saved = nil
        @children_saved = nil
        @body_saved= nil
      end

      # Duplicate the ResourceState but link it to another session
      def new_for_session(session)
        new_persistor = session.persistor_for(persistor.model)
        new_persistor.create_resource_state(nil, id)
      end
    end
  end
end

