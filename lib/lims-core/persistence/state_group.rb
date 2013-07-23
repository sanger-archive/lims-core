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
        # split by status
        group_by(&:save_action).tap do |groups|
          persistor.bulk_insert(groups[:insert])
          # persistor.bulk_update(groups[:update])
          # persistor.bulk_delete(groups[:delete]) to do later
        end
      end
    end
  end
end
