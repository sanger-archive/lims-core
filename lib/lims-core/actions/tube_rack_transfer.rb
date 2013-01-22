# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'
require 'lims/core/laboratory/tube_rack'

module Lims::Core
  module Actions
    # This action transfers the content of a source tube rack
    # to a target tube rack according to a transfer map.
    class TubeRackTransfer
      include Action

      attribute :source, Laboratory::TubeRack, :required => true, :writer => :private
      attribute :target, Laboratory::TubeRack, :required => true, :writer => :private
      attribute :transfer_map, Hash, :required => true, :writer => :private

      # Transfer the content from a source tube rack to a target
      # tube rack according to a transfer map. If the transfer
      # map specifies a target location which is actually empty
      # (no tube), a NoTubeInSpecifiedLocation exception is raised.
      # If the transfer map specifies a source location which is 
      # empty (no tube), nothing happens.
      def _call_in_session(session)
        transfer_map.each do |from, to|
          raise NoTubeInSpecifiedLocation, "#{to} location is empty" unless target[to].is_a? Laboratory::Tube

          unless source[from].nil?
            target[to] = source[from].take_fraction(1)
          end
        end
        target
      end
    end
  end
end
