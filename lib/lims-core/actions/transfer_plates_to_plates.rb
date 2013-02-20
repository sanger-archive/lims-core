require 'lims/core/actions/action'

module Lims::Core
  module Actions

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
    class TransferPlatesToPlates
      include Action

      attribute :transfers, Array, :required => true, :writer => :private

      def _validate_parameters
        raise ArgumentError, "The transfer array should not be null." unless transfers
        raise ArgumentError, "You should give the fraction OR the amount of the transfer, not both." unless valid_amount_and_fraction
      end

      def valid_amount_and_fraction
        valid = true
        transfers.each do |transfer|
          if (transfer["fraction"].nil? && transfer["amount"].nil?) || (transfer["fraction"] && transfer["amount"])
            valid = false
            break
          end
        end
        valid
      end

      def _call_in_session(session)
        sources = []
        targets = []
        amounts = []

        transfers.each do |transfer|
          # simplify the transfer related variables
          source = transfer["source"]
          from = transfer["source_location"]
          fraction = transfer["fraction"]
          amount = transfer["amount"]

          # Converts the fraction to the amount of the aliquot
          # and use it later when transfering to the target asset
          if fraction
            amounts << source[from].quantity * fraction
          else
            amounts << amount
          end
        end

        transfers.zip(amounts) do |transfer, amount|
          # simplify the transfer related variables
          source = transfer["source"]
          from = transfer["source_location"]
          target = transfer["target"]
          to = transfer["target_location"]
          aliquot_type = transfer["aliquot_type"]

            # do the element transfer according to the given transfer map
          target[to] << source[from].take_amount(amount)

          # change the aliquot_type of the target
          unless aliquot_type.nil?
            target[to].each do |aliquot|
              aliquot.type = aliquot_type
            end
          end

          sources << source
          targets << target

        end

        { :sources => sources.uniq, :targets => targets.uniq}
      end
    end
  end
end
