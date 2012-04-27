# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/tag_group'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      # Not a tag_group but a tag_group persistor.
      class TagGroup < Persistence::TagGroup
        include Sequel::Persistor


         def save_raw_association(tag_group_id, oligo_id, position)
            Association::dataset(@session).insert(:tag_group_id => tag_group_id,
                           :position => position,
                           :oligo_id  => oligo_id)
          end

         def delete_children(id, group)
           return unless id.present?
           Association::dataset(@session).filter(primary_key => id).delete
         end


         class Association < Persistence::TagGroup::Association
           include Sequel::Persistor
           def self.table_name
             :tag_group_associations
           end

           # Load each oligos and pass them to the block
           # @param [Id] group_id id of the Tag group
           # @yield_param [Oligo] oligo Object created or loaded
           # @yield_param [Fixnum] position the index of Oligo in the TagGroup.
           def load_oligos(group_id, &block)
             dataset.join(Oligo::dataset(@session), :id => :oligo_id).filter(:tag_group_id => group_id).order(:position).each do |att|
               position = att.delete(:position)
               oligo_id = att.delete(:oligo_id)
               att.delete(:group_id)
               oligo = @session.oligo.get_or_create_single_model(oligo_id) { Oligo::Model.new(att) }
               block.call(oligo, position) if block
             end
           end
         end
      end
    end
  end
end
