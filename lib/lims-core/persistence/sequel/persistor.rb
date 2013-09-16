# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/identity_map'
require 'active_support/inflector'
require 'lims-core/persistence/sequel/filters'

module Lims::Core
  module Persistence
    module Sequel
      # Mixin giving extended the persistor classes with
      # the Sequel (load/save) behavior.
      module Persistor

        include Filters

        def self.included(klass)
          klass.class_eval do
            # @return [String] the name of SQL table.
            def self.table_name
              @table_name ||= parent_scope.name.split('::').last.pluralize.snakecase.to_sym
            end
            # The Sequel::Dataset.
            # Corresponds to table.
            # @param [Sequel::Session] session 
            # @return [::Sequel::Dataset]
            def self.dataset(session)
              session.database[self.table_name]
            end
          end
        end

        def initialize(session_or_persistor, dataset=nil, *args, &block )
          id_to_state, object_to_state = [nil, nil]
          case session_or_persistor
          when Sequel::Persistor
            # We link the session and the identity map variables,
            # so that object loaded via this persistor can be found (and their id)
            # through the origial persistor.
            # Hack to get those private variables.
            session, identity_map_parameters  =  session_or_persistor.instance_eval do
              [@session, [@id_to_state, @object_to_state]]
            end
            super(session, *args, &block)
            @id_to_state , @object_to_state = identity_map_parameters
          else Session
            super(session_or_persistor, *args, &block)
          end

          @dataset = dataset || self.class.dataset(@session)
        end

        # @return  [String] the name of the table
        def table_name
          self.class.table_name
        end


        # The Sequel::Dataset.
        # Corresponds to a table.
        # @return [::Sequel::Dataset]
        def dataset
          @dataset
        end


        # Returns the number of object in the store
        # @return [Fixnum]
        def count
          dataset.count
        end

        protected
        # load a slice.
        def for_each_in_slice(start, length)
          return if length == 0
          dataset.order(primary_key).limit(length, start).each do |h|
            yield(h)
          end
        end

        # The primary key 
        # @return [Symbol]
        def primary_key()
          :id
        end

        def qualified_key
          @qualified_key ||= ::Sequel.qualify(self.class.table_name, primary_key)
        end

        def bulk_load(ids, *params, &block)
          dataset.filter(qualified_key => ids.map(&:id)).all(&block)
        end
        public :bulk_load

        def ids_for(criteria)
          dataset.select(qualified_key).filter(criteria).map { |h| h[primary_key] }

        end

        # Save a raw object, i.e. the object
        # attributes excluding any associations.
        # @param [Resource] object the object 
        # @return [Fixnum, nil] the Id if save successful
        def insert(state, *params)
          # use prepared statement for everything
          # We only need it at the moment as a workaround for saving the UUID
          # So we might in the future either move it to a UuidResourcePersistor
          # or cached it by attributes
          # @todo benchmark against normal insert
          attributes = filter_attributes_on_save(state.resource.attributes, *params)
          dataset.insert(attributes).tap { |id| state.id = id }
        end

        def bulk_insert(states, *params)
          #super(states, *params)
          bulk_insert_multi(states, *params)
          #bulk_insert_prepared(states, *params)
        end
        public :bulk_insert

        def bulk_insert_prepared(states, *params)
          # use prepared statement for everything
          # We only need it at the moment as a workaround for saving the UUID
          # So we might in the future either move it to a UuidResourcePersistor
          # or cached it by attributes
          # @todo benchmark against normal insert
            attributes = filter_attributes_on_save(states.first.resource.attributes, *params)
          statement_name = :"#{table_name}__save_raw"
          dataset.prepare(:insert, statement_name, attributes.keys.mash { |k| [k, :"$#{k}"] })

          states.each do |state|
            attributes = filter_attributes_on_save(state.resource.attributes, *params)
            @session.database.call(statement_name, attributes)
          end
        end

        # @todo
        def bulk_insert_multi(states, *params)
          free_ids = get_next_available_ids(states.size)
          states.inject(0) { |i,s| s.id = free_ids[i]; i+1 }
          attributes = states.map { |state| filter_attributes_on_save(state.resource.attributes, *params).merge(primary_key => state.id) }
          dataset.multi_insert(attributes)
        end

        def bulk_update_raw_attributes(attributes, *params)
          return dataset.on_duplicate_key_update.multi_insert(attributes) if dataset.respond_to? :on_duplicate_key_update
          attributes.each { |att| dataset.filter(primary_key => att.delete(primary_key)).update(att) }
        end

        def bulk_delete_raw(ids, *params)
          dataset.filter(primary_key => ids).delete
        end

        def delete_raw(objec, id, *params)
          id.tap do
            dataset.filter(primary_key => id).delete
          end
        end

        # Return a sequence of free ids, ready to be inserted.
        # The last used id corresponding to each table is store in a special table.
        # We need to lock the table to avoid to thread or process to 'use' the same ids.
        # @param [Integer] quantity
        # @return [Array<Integer>]
        def get_next_available_ids(quantity = 1)
          @session.lock(dataset.from(:primary_keys)) do |primary_keys|
            current_key_row = primary_keys.first(:table_name => table_name.to_s) 
            if current_key_row
              current_key = current_key_row[:current_key]
            else
              # We need to lock the current dataset otherwise MySQL raise on error
              # because we are already in a LOCK block.
              current_key = @session.lock(dataset) { |d| d.max(primary_key) } || 0
              primary_keys.insert(:table_name => table_name.to_s, :current_key => current_key)
            end

            new_current_key = current_key + quantity
            primary_keys.where(:table_name => table_name.to_s).update(:current_key => new_current_key)

            (current_key+1..new_current_key).to_a
          end
        end
        public :get_next_available_ids
      end
    end
  end
end
require 'lims-core/persistence/sequel/filters'
