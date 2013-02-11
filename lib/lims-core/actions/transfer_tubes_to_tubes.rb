require 'lims/core/actions/action'

require 'lims/core/laboratory/spin_column'
require 'lims/core/laboratory/tube'

module Lims::Core
  module Actions

    # This {Action} transfers the given fraction and type of aliquot from tube-like asset(s)
    # to tube-like asset(s).
    # It takes an array, which contains transfer elements. 
    # An element has a source, target, amount, fraction and type parameter.
    # Source and targets are tube-like assets (a tube or spin column).
    # Amount is an amount of an aliquot to transfer.
    # Fraction is the fraction of an aliquot to transfer.
    # Type is the type of the aliquot.
    class TransferTubesToTubes
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

      # transfer the given fraction of aliquot from tube-like asset(s)
      # to tube-like asset(s)
      def _call_in_session(session)
        sources = []
        targets = []
        transfers.each do |transfer|
          fraction = transfer["fraction"]
          next unless fraction
          amount = transfer["source"].quantity * fraction
          transfer["amount"] = amount
        end

        transfers.each do |transfer|
          source = transfer["source"]
          target = transfer["target"]
          target << source.take_amount(transfer["amount"])

          unless transfer["aliquot_type"].nil?
            target.each do |aliquot|
              aliquot.type = transfer["aliquot_type"]
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
