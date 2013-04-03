# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims-core/persistence/persistor'
require 'lims-core/laboratory/tag_group'

module Lims::Core
  module Laboratory

    # Base for all Plate persistor.
    # Real implementation classes (e.g. Sequel::Plate) should
    # include the suitable persistor.
    class TagGroup
      class TagGroupPersistor < Persistence::Persistor
        Model = Laboratory::TagGroup

        # Save all children of the given group
        # @param  id object identifier
        # @param [Laboratory::TagGroup] group
        # @return [Boolean]
        def save_children(id, group)
          group.each_with_index do |oligo, position|
            next unless oligo
            save_as_aggregation(id, oligo, position)
          end
        end

        # Load all children of the given group
        # Loaded object are automatically added to the session.
        # @param  id object identifier
        # @param [Laboratory::Plate] group
        # @return [Laboratory::Plate, nil] 
        #
        def load_children(id, group)
          association.load_oligos(id) do |oligo, position|
            group << nil while (group.size <= position)
            group[position] = oligo
          end
        end


        def association
          @session.send("TagGroup::Association")
        end

        # This class doesn't exist in the model
        # but is there to modelize the association.
        # It probably correspond to one table on the database.
        class Association < Persistence::Persistor
        end
      end
    end
  end
end
