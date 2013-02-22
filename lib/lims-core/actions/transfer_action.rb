module Lims::Core
  module Actions
    module TransferAction

      def self.included(klass)
        klass.class_eval do
          include Virtus
          include Aequitas
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

          # Converts the fraction to amount and store it in an array
          def _amounts(transfers)
            amounts = []
            transfers.each do |transfer|
              # simplify the transfer related variables
              source = transfer["source"]
              from = transfer["source_location"]
              fraction = transfer["fraction"]
              amount = transfer["amount"]

              # in case if plate-like object
              source = source[from] if from

              # Converts the fraction to the amount of the aliquot
              # and use it later when transfering to the target asset
              if fraction
                amounts << source.quantity * fraction
              else
                amounts << amount
              end
            end
            amounts
          end

          # Do the transfers from source asset(s) to target asset(s)
          # It is working for tube-like and plate-like asset(s), too.
          def _transfer(transfers, amounts)
            sources = []
            targets = []

            transfers.zip(amounts) do |transfer, amount|
              # simplify the transfer related variables
              source = transfer["source"]
              from = transfer["source_location"]
              target = transfer["target"]
              to = transfer["target_location"]
              aliquot_type = transfer["aliquot_type"]

              # do the element transfer according to the given transfer (map)
              if target.class == Lims::Core::Laboratory::TubeRack
                tube = Lims::Core::Laboratory::Tube.new
                session << tube
                target[to] = tube
              end

              _target, _source = nil, nil
              if from
                _source = source[from]
                _target = target[to]
              else
                _source = source
                _target = target
              end
              _target << _source.take_amount(amount)

              # change the aliquot_type of the target
              unless aliquot_type.nil?
                _target.each do |aliquot|
                  aliquot.type = aliquot_type
                end
              end

              sources << _source
              targets << _target

            end

            { :sources => sources.uniq, :targets => targets.uniq}
          end

        end
      end
    end
  end
end
