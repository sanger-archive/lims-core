module Lims::Core
  module Actions
    module TransferAction

      def self.included(klass)
        klass.class_eval do

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
                amounts << (source.quantity ? source.quantity * fraction : nil)
              else
                amounts << amount
              end
            end
            amounts
          end

          # Do the transfers from source asset(s) to target asset(s)
          # It is working for tube-like and plate-like asset(s), too.
          def _transfer(transfers, amounts, session)
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

              sources << source
              targets << target

            end

            { :sources => sources.uniq, :targets => targets.uniq}
          end

          def _transfers
            transfers = []
            transfer_map.each do |from, to|
              transfers <<
                { "source" => source,
                  "source_location" => from,
                  "target" => target,
                  "target_location" => to,
                  "fraction" => 1,
                  "aliquot_type" => aliquot_type
                }
            end
            transfers
          end

        end
      end
    end
  end
end
