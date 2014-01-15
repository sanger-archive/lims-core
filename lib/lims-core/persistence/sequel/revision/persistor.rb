require 'lims-core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      module Revision
        module Persistor
          def self.included(klass)
            klass.class_eval do
              include Sequel::Persistor
              def self.table_name
                :"#{super}_revision"
              end
            end
            
            def session_id
              @session.session_id
            end


            def find_ids_from_internal_ids(internal_ids)
              dataset.select_group(:internal_id).
                select_more{::Sequel.as(max(:session_id), :session_id)}.filter(:internal_id => internal_ids.map(&:id), :session_id => 1..session_id )
            end
            
            def  bulk_load(ids, *params, &block)
              internal_ids_set = find_ids_from_internal_ids(ids)
              dataset.join(internal_ids_set,
                :internal_id => :internal_id,
                :session_id => :session_id
              ).all do |row|
                # @todo move in new from attributes ???
                id = row.delete(:id)
                type = row.delete(:type)
                action = row.delete(:action)
                revision = row.delete(:revision)
                row[:id] = row.delete(:internal_id)
                session_id = row.delete(:session_id)
                if action == 'delete'
                  block.call(nil)
                else
                block.call(row)
              end
              end
            end
          end
        end
      end
    end
  end
end
