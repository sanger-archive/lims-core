require 'common'

module Lims::Core
  module Laboratory
    # A labellable is something which can have one or more labels.
    # By labels we mean any readable information found on a physical oblect.
    # This can be serial number, stick label with barcode etc.
    # {Label} can eventually be identified by a position : an arbitrary number.
    # The semantic of the position is left to pipeline.
    module Labellable
      def labels()
        []
      end

      # @param [String] message
      # @param [Integer, nil] position
      # @return [Label]
      def add_label(message, position=nil)
      end

      def update_label(message, position=nil)
      end
    end
  end
end
