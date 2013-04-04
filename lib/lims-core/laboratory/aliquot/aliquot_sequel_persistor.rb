# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/laboratory/aliquot/aliquot_persistor'
require 'lims-core/laboratory/oligo/oligo_persistor'
require 'lims-core/persistence/sequel/persistor'

module Lims::Core
  module Laboratory
    # Not a aliquot but a aliquot persistor.
    class Aliquot
      class AliquotSequelPersistor < AliquotPersistor
        include Persistence::Sequel::Persistor
        def self.table_name
          :aliquots
        end

        def filter_attributes_on_save(attributes)
          attributes.mash do |k,v|
            case k
            when :tag then [:tag_id, @session.id_for!(v)]
            when :sample then [:sample_id, @session.id_for!(v)]
            else [k, v]
            end
          end
        end

        def filter_attributes_on_load(attributes)
          attributes.mash do |k,v|
            case k
            when :tag_id then [:tag, @session.oligo[v]]
            when :sample_id then [:sample, @session.sample[v]]
            else [k, v]
            end
          end
        end

      end
    end
  end
end
