require 'lims-core/actions/action'
require 'lims-core/laboratory/transfer_action'
require 'lims-core/laboratory/transfers_parameters'

module Lims::Core
  module Laboratory

    # This {Action} transfers the given fraction and type of aliquot from plate-like asset(s)
    # to plate-like asset(s).
    # It takes an array, which contains transfer elements.
    # An element has a source, source_location, target, target_location,
    # amount/fraction and aliquot_type parameters.
    # Source and targets are plate-like assets (plates, gel plates or tube racks).
    # The source/target_location is the well/window/tube location (like "A1") from
    # transfer the aliquots and to transfer the aliquots.
    # Amount is an amount of an aliquot to transfer.
    # Fraction is the fraction of an aliquot to transfer.
    # You should give the fraction OR the amount of the transfer, not both of them.
    # Aliquot_type is the type of the aliquot (DNA, RNA, NA, sample etc...).
    class Plate
      class TransferPlatesToPlates
        include Actions::Action
        include TransferAction
        include TransfersParameters

        # transfer the given fraction of aliquot from plate-like asset(s)
        # to plate-like asset(s)
        def _call_in_session(session)

          _transfer(transfers, _amounts(transfers), session)

        end
      end
    end
  end
end
