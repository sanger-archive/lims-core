# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/identity_map'


module Lims::Core
  module Persistence
    module Sequel
      # Mixin giving persistor (load/save) behavior.
      # The base class, needs to implements a `self.model`
      # returning the class to persist.
      # Each instance can get an identity map, and or parameter
      # specific to a session/thread.
      module Persistor
        def self.included(klass)
          klass.class_eval do
            include IdentityMap
            # @return [String] the name of SQL table.
            def table_name
              raise NotImplementedError
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

        def initialize (session, *args, &block)
          @session = session
          super(*args, &block)
        end

        # Associate class (without persistence).
        # @return [Class]
        def model
          self.class::Model
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

        # Load a model by id 
        # Note that loaded object are automatically _added_ to the session.
        # @param [Fixnum] id the id in the database
        # @return [Object,nil] nil if  object not found.
        def [](id)
          case id
          when Fixnum then load_single_model(id)
          end
        end

        # save an object and return is id or nil if failure
        # @return [Fixnum, nil]
        def save(object, *params)
          id_for(object) { |id| update(object, id, *params) } ||
            map_id_object(save_new(object, *params) , object)
        end

        # Load a model object (and its children) from its database id.
        # @param id id in the database
        # @return [Resource] the model object.
        # @raises error if object doesn't exists.
        def load_single_model(id)
          object_for(id) || model.new(dataset[:id => id]).tap do |m|
            map_id_object(id, m)
            load_children(id, m)
            @session.on_object_load(m)
          end
        end

        private
        # The primary key 
        # @return [Symbol]
        def primary_key()
          :id
        end

        # Called to save a new object, i.e. which is not
        # already in the database.
        # @param [Resource] object the object 
        # @return [Fixnum, nil] the Id if save successful
        def save_new(object, *params)
          dataset.insert(object.attributes).tap do |id|
            save_children(id, object)
          end
        end

        # Save a object already in the database
        # @param [Resource] object the object 
        # @param [Fixum] id id in the database
        # @return [Fixnum, nil] the Id if save successful.
        def update(object, id, *params)
          # naive version , update everything.
          # Probably quicker than trying to guess what has changed
          id.tap do
            dataset[primary_key => id].update(object.attributes)
            update_children(id, object)
          end
        end

        # save children of a newly created object.
        # @param [Fixum] id id in the database
        # @param [Resource] object the object 
        def save_children(id, object)
        end

        # save children of an existing object.
        # @param [Fixum] id id in the database
        # @param [Resource] object the object 
        def update_children(id, object)
          delete_children(id, object)
          save_children(id, object)
        end

        def delete_children(id, object)
        end

        # Loads children from the database and set the to model object.
        # @param id primary key of the model object in the database.
        # @param m  instance of model to load
        def load_children(id, m)
        end
      end
    end
  end
end
