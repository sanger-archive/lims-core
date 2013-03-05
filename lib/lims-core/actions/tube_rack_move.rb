# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en 
require 'lims/core/actions/action'
require 'lims/core/laboratory/tube_rack'

module Lims::Core
  module Actions
    # This {Action} moves physically tubes from source racks
    # to target racks.
    # It takes an array, which contains the elements of the movement.
    # An element has a source, source_location, target and target_location.
    # Source and targets are tube racks.
    # The source/target_location is the tube location (like "A1") from
    # move the tube and to move the tube.
    class TubeRackMove
      include Action

      attribute :moves, Array, :required => true, :writer => :private

      # Move tubes from source tube racks to target
      # tube racks. If a tube is already present in the
      # target location, a RackPositionNotEmpty exception
      # is raised in the Laboratory::TubeRack class.
      # The tube is removed from the source tube rack 
      # after moving to its target location.
      def _call_in_session(session)
        targets = []
        moves.each do |move|
          source = move["source"]
          from = move["source_location"]
          target = move["target"]
          to = move["target_location"]

          unless source[from].nil?
            target[to] = source[from]
            source[from] = nil
          end

          targets << target
        end

        targets.uniq
      end

    end
  end
end
