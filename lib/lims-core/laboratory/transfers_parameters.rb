module Lims::Core
  module Laboratory

    # This module holds the parameter of transfer related action like TransfersPlatesToPlates
    # and TransferTubesToTubes and the validation of these parameters.
    module TransfersParameters

      def self.included(klass)
        klass.class_eval do
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

        end
      end
    end
  end
end
