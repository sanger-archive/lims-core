# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'lims-core/persistence/resource_state'
module Lims::Core
  module Persistence
    # A immutable list of {ResourceState}.
    class StateList < Array
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
      %w(select map).each do |method|
        define_method(method) do |&block|
          new { super(&block) }
        end
      end
      
      def new(&block)
        self.class.new(block.call)
      end

      def save
        groups.each do |group|
          group.save
        end
      end
    end
  end
end
require 'lims-core/persistence/state_group'
