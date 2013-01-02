require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  module Persistence

    class SangerBarcode < Persistor
      Model = Laboratory::SangerBarcode

      def filter_attributes_on_save(attributes, labellable_id=nil, position=nil)
        attributes[:position] = position if position
        attributes[:labellable_id] = labellable_id if labellable_id
        attributes
      end
    end
  end
end
