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
          next unless state.resource
          state.parents!.andtap do |parents|
            all_parents.concat(parents)
          end
        end
        all_parents.save

        # split by status
        group_by(&:save_action).tap do |groups|
          groups[:insert].andtap { |group| persistor.bulk_insert(group) }
          groups[:update].andtap { |group| persistor.bulk_update(group) }
          # persistor.bulk_delete(groups[:delete]) to do later
        end

        all_children = StateList.new
        each do |state|
          next unless state.resource
          state.body_saved!
          state.children!.andtap do |children|
            all_children.concat(children)
          end
        end
        all_children.save
      end

      def load(*params)
        to_load = select(&:to_load?)
        all_parents = StateList.new
        attributes_list = []
        persistor.bulk_load(to_load, *params) do |att|
            all_parents.concat(persistor.parents_for_attributes(att))
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
