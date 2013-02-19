require 'lims/core/actions/action'

module Lims::Core
  module Actions
    class TransferPlatesToPlates
      include Action

      attribute :transfers, Array, :required => true, :writer => :private

      def _call_in_session(session)
        sources = []
        targets = []
        transfers.each do |transfer|
          source = transfer["source"]
          target = transfer["target"]
          transfer_map = transfer["transfer_map"]
          aliquot_type = transfer["aliquot_type"]

            # do the element transfer according to the given transfer map
          transfer_map.each do |from, to|
            target[to] << source[from].take_fraction(1)

            # change the aliquot_type of the target
            unless aliquot_type.nil?
              target[to].each do |aliquot|
                aliquot.type = aliquot_type
              end
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
