# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/flowcell'

module Lims::Core
  module Persistence
    # @abstract
    # Base for all Flowcell persistor.
    # Real implementation classes (e.g. Sequel::Flowcell) should
    # include the suitable persistor.
    class Flowcell < Persistor
      Model = Laboratory::Flowcell

      # @abstract
      # Base for all Lane persistor.
      # Real implementation classes (e.g. Sequel::Lane) should
      # include the suitable persistor.
      class Lane < Persistor
        Model = Laboratory::Flowcell::Lane
        def save(lane, flowcell_id, position)
          #todo bulk save if needed
          lane.each do |aliquot|
            save_as_aggregation(flowcell_id, aliquot, position)
          end
        end
      end
    end
  end
end
