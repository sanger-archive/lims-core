# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/order'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      # Not a order but a order persistor.
      class Order < Persistence::Order
        include Sequel::Persistor
        def self.table_name
          :orders
        end

        def filter_attributes_on_save(attributes)
          attributes.mash do |k,v|
            case k
              # get id of object
            when  :creator then [:creator_id, @session.id_for(v)]
            when :study then [:study_id, @session.id_for(v)]
              # serialize structured object
            when :parameters, :state then [k, Marshal.dump(v) ]
            else [k, v]
            end
          end
        end

        def filter_attributes_on_load(attributes)
          attributes.mash do |k,v|
            case k
            when :creator_id then [:creator, @session.user[v]]
            when :study_id then [:study, @session.study[v]]
            when :parameters, :state then [k, Marshal.load(v) ]
            else [k, v]
            end
          end
        end
      end
    end
  end
end
