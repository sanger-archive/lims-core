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
      attribute :resource, Object, :writer => :private, :required => true
      attribute :persistor, Persistor, :writer => :private, :required => true
      attribute :to_delete, Object, :writer => :private

      def initialize(resource, persistor, id=nil)
        @resource=resource
        @persistor=persistor
        @id=id
        @to_delete = false
      end

      def new?
        @id == nil
      end

      def dirty?
        true
      end

      def id=(new_id)
        raise RuntimeError, "modifing existing id not allowed. #{self}"   if @id
        @id = new_id
        # link the new id in th id_to_state map
        @persistor.bind_state_to_id(self)
      end

      def mark_for_deletion
        @to_delete = true
      end

      # @todo use state machine ?
      def save_action
        case
        when to_delete && !new? then :delete
        when new? then :insert
        when dirty? then :update
        end
      end

      def dirty?
        true
      end

    end
  end
end

