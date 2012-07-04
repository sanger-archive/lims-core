# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/identity_map'
require 'active_support/inflector'


module Lims::Core
  module Persistence
    module Sequel
      # Mixin giving extended the persistor classes with
      # the Sequel (load/save) behavior.
      module Persistor
        def self.included(klass)
          klass.class_eval do
            # @return [String] the name of SQL table.
            def self.table_name
              @table_name ||= name.split('::').last.pluralize.snakecase.to_sym
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

        # @return  [String] the name of the table
        def table_name
          self.class.table_name
        end


        # The Sequel::Dataset.
        # Corresponds to a table.
        # @return [::Sequel::Dataset]
        def dataset
          self.class.dataset(@session)
        end


        private
        # The primary key 
        # @return [Symbol]
        def primary_key()
          :id
        end

        def load_raw_attributes(id, raw_attributes=nil)
          dataset[primary_key => id ]
        end

        def ids_for(criteria)
          # Use prepared statement
          # @todo cache prepared statement or move in UuidResourcePersistor
          # OLD dataset.select(primary_key)[criteria] || []
          #
          ds=dataset.select(primary_key).filter(criteria.keys.mash { |k| [k, :"$#{k}"] })
          statement_name = :"#{table_name}#ids_for"
          ds.prepare(:select, statement_name)

          # for some reason, the prepared statement return an array of Hashes insteead
          # of an array of ids, as data.select(primary_key) will do
          (@session.database.call(statement_name, criteria) || []).map { |h| h[primary_key] }

        end

        # Save a raw object, i.e. the object
        # attributes excluding any associations.
        # @param [Resource] object the object 
        # @return [Fixnum, nil] the Id if save successful
        def save_raw(object, *params)
          # use prepared statement for everything
          # We only need it at the moment as a workaround for saving the UUID
          # So we might in the future either move it to a UuidResourcePersistor
          # or cached it by attributes
          # @todo benchmark against normal insert
          attributes = filter_attributes_on_save(object.attributes)
          statement_name = :"#{table_name}#save_raw"
          dataset.prepare(:insert, statement_name, attributes.keys.mash { |k| [k, :"$#{k}"] })
          @session.database.call(statement_name, attributes)
        end

        # Upate a raw object, i.e. the object attributes
        # excluding any associations.
        # @param [Resource] object the object 
        # @param [Fixnum] id the Id of the object
        # @return [Fixnum, nil] the id 
        def update_raw(object, id, *params)
          id.tap do
            dataset[primary_key => id].update(object.attributes)
          end
        end
      end
    end
  end
end
