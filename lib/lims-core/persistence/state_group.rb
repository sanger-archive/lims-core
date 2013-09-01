# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'lims-core/persistence/state_list'
module Lims::Core
  module Persistence
    # A immutable list of {ResourceState}.
    class StateGroup < StateList
      attr_reader :persistor
      def initialize(persistor, states)
        @persistor = persistor
        super(states)
      end
      def groups
        [self]
      end

      def new(&block)
        self.class.new(self.persistor, block.call)
      end

      def save
        # @todo method for that.
        all_parents = StateList.new
        each do |state|
          next if state.resource == nil or state.to_delete
          state.parents!.andtap do |parents|
            all_parents.merge(parents)
          end
        end

        all_parents.save

        persistor.purge_invalid_object

        # split by status
        group_by(&:save_action).tap do |groups|
          groups[:insert].andtap { |group| persistor.bulk_insert(group) }
          groups[:update].andtap { |group| persistor.bulk_update(group) }
          groups[:delete].andtap { |group|  StateGroup.new(persistor, group).destroy }
        end

        all_children = StateList.new
        each do |state|
          next unless state.resource
          state.body_saved!
          state.children!.andtap do |children|
            all_children.merge(children)
          end
        end
        all_children.save
      end

      # @todo doc
      # destroy because delete exists already for a Set
      def destroy
        return self if size == 0
         # mark each item for deletion
         # so the parents are not saved later.
         # children needs to be deleted NOW to avoid
         # foreign key constraint error.
          each_with_object(StateList.new) do |state, list|
            # don't delete children if they've been deleted already
            next if state.children_saved?
            state.mark_for_deletion
            list.merge(persistor.deletable_children_for(state.resource))
            state.children_saved!
          end.destroy

        
        persistor.bulk_delete(self.select { |s| !s.body_saved? })

          each_with_object(StateList.new) do |state, list|
            next if state.parents_saved?
            list.merge(persistor.deletable_parents_for(state.resource))
            state.parents_saved!
          end.destroy
        each { |state| state.body_saved! }

      end

      def load(*params)
        to_load = select(&:to_load?)
        all_parents = StateList.new
        attributes_list = []
        persistor.bulk_load(to_load, *params) do |att|
          all_parents.merge(persistor.parents_for_attributes(att))
          attributes_list << att
        end
        all_parents.load(*params)
        attributes_list.map do |att|
          persistor.new_from_attributes(att)
        end
        persistor.load_children(self, *params)
        self
      end
    end
  end
end
