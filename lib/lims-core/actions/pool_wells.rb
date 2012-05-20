# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/laboratory/plate'

module Lims::Core
  module Actions
    class PoolWells
      include Action

      attribute :source, Laboratory::Plate, :writer => :private
      attribute :target, Laboratory::Plate, :writer => :private
      attribute :pools, Hash, :writer => :private
      attribute :pool_to_well_map, Hash, :writer => :private
      def _call_in_session(session)
        pools.each do |pool, wells|
          target_well_name = pool_to_well_map[pool]
          raise RuntimeError, "Can't find destination well for pool '#{pool}'" unless target_well_name
          target[target_well_name] << wells.map { |w| source[w].take }.flatten
        end
      end
    end
  end
end
