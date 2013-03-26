module Lims::Core
  module Laboratory
    module Container::ContainerElementSequelPersistor

      def save_raw_association(container_id, aliquot_id, position)
          dataset.insert(container_id_sym => container_id,
                         :position => position,
                         :aliquot_id  => aliquot_id)
      end

      # Do a bulk load of aliquot and pass each to a block
      # @param container_id the id of the container to load.
      # @yieldparam [Integer] position
      # @yieldparam [Aliquot] aliquot
      def load_aliquots(container_id)
        element_dataset.join(Aliquot::dataset(@session), :id => :aliquot_id).filter(container_id_sym => container_id).each do |att|
          position = att.delete(:position)
          att.delete(:id)
          aliquot  = @session.aliquot.get_or_create_single_model(att[:aliquot_id], att)
          yield(position, aliquot)
        end
      end

    end
  end
end
