# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'
require 'lims/core/actions/transfer_action'

require 'lims/core/laboratory/plate'

module Lims::Core
  module Actions
    # This {Action}  transfer the content between too plate.
    # At the moment there are no quantity associated  to the transfer.
    # It take a source and a target plate and a map telling which wells go in were.
    # For more details, see attributes.
    class PlateTransfer
      include Action
      include TransferAction

      attribute :source, Laboratory::Plate, :required => true, :writer => :private
      attribute :target, Laboratory::Plate, :required => true, :writer => :private
      attribute :transfer_map, Hash, :required => true, :writer => :private
      attribute :aliquot_type, String, :required => false, :writer => :private


      # transfer the content of from source to target according to map
      # If aliquot_type is given, it sets the type on all the aliquots
      # of the target plate.
      def _call_in_session(session)
        transfers = _transfers
        transfer_hash = _transfer(transfers, _amounts(transfers), session)
        transfer_hash[:targets].first
      end

    end
  end
end
