# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en 
require 'lims/core/actions/action'
require 'lims/core/laboratory/tube_rack'

module Lims::Core
  module Actions
    class TubeRackMove
      include Action

      attribute :source, Laboratory::TubeRack, :required => true, :writer => :private
      attribute :target, Laboratory::TubeRack, :required => true, :writer => :private
      attribute :move_map, Hash, :required => true, :writer => :private


      class TubePresentInTargetLocation < StandardError
      end

      def _call_in_session(session)
        move_map.each do |from, to|
          raise TubePresentInTargetLocation, "#{to} location is not empty" unless target[to].nil?

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
