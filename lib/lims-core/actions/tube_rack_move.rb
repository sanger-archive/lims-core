# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en 
require 'lims/core/actions/action'
require 'lims/core/laboratory/tube_rack'

module Lims::Core
  module Actions
    # This action moves physically tubes from a source rack
    # to a target rack according to a transfer map.
    class TubeRackMove
      include Action

      attribute :source, Laboratory::TubeRack, :required => true, :writer => :private
      attribute :target, Laboratory::TubeRack, :required => true, :writer => :private
      attribute :move_map, Hash, :required => true, :writer => :private

      # Move tubes from a source tube rack to a target
      # tube rack. If a tube is already present in the
      # target location, a RackPositionNotEmpty exception
      # is raised in the Laboratory::TubeRack class.
      # The tube is removed from the source tube rack.
      def _call_in_session(session)
        move_map.each do |from, to|
          unless source[from].nil?
            target[to] = source[from]
            source[from] = nil
          end
        end
        target
      end
    end
  end
end
