# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-core/laboratory/plate'
require 'lims-core/laboratory/tube'

module Lims::Core
  module Laboratory
    # This {Action}  transfer the content between too plate.
    # At the moment there are no quantity associated  to the transfer.
    # It take a source and a target plate and a map telling which wells go in were.
    # For more details, see attributes.
    class Tube
      class TransferWellsToTubes
        include Actions::Action

        attribute :plate, Laboratory::Plate, :required => true, :writer => :private
        attribute :well_to_tube_map, Hash, :required => true, :writer => :private

        def _validate_parameters
          tubes = well_to_tube_map.values
          raise InvalidParameters, "Many wells go in the same tube" if tubes.uniq.size != tubes.size
        end
        # transfer the content of  from source to target according to map
        def _call_in_session(session)
            well_to_tube_map.each do |well , tube|
              tube << plate[well].take_fraction(1)
            end
        end
      end
    end
  end
end
