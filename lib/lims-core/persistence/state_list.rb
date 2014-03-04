# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'lims-core/persistence/resource_state'
require 'set'
module Lims::Core
  module Persistence
    # A immutable list of {ResourceState}.
    class StateList < Set
      # @return [List<StateGroup>]
      def groups
        persistor_order = map { |state| state.persistor}.uniq
        grouped = group_by { |state| state.persistor }
        persistor_order.map do  |persistor|
            StateGroup.new(persistor, grouped[persistor])
          end
      end

      # We need to redefine some basic array function
      # to keep the current class and not return an array
      %w(select).each do |method|
        define_method(method) do |&block|
          new { super(&block) }
        end
      end

      def map_as_state_list(&block)
        new { map(&block) }
      end

      def new(&block)
        self.class.new(block.call)
      end

      def save
        groups.each do |group|
          group.save
        end
      end

      def destroy
        groups.each do |group|
          group.destroy
        end
      end

      # @todo return object according to initial order ?
      def load
        groups.each do |group|
          group.load
        end
      end

      def reset_status
        each { |state|
          state.reset }
      end

    end
  end
end
require 'lims-core/persistence/state_group'
