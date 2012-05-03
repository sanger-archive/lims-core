# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/identity_map'


module Lims::Core
  module Persistence
    # @abstract Base class for all the persistors, needs to implements a `self.model`
    # returning the class to persist.
    # A persistor , is used to save and load it's cousin class.
    # The specific code of a persistor should be extended by writting
    # a persistor module in the sub-persistence module. This module will be 
    # automatically included to generated class. See {Persistence::finalize_module}.
    # Each instance can get an identity map, and or parameter
    # specific to a session/thread.
    class Persistor
      include IdentityMap

      def initialize (session, *args, &block)
        @session = session
        super(*args, &block)
      end

      # Associate class (without persistence).
      # @return [Class]
      def model
        self.class::Model
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

      # save an association
      # Association doesn't have necessarily and id
      # therefore we don't use the indentity map.
      # Save objects if needed.
      # @param [Resource, Id] source the source of the association.
      # @param [Resource, Id] target the target of the association.
      # @param [Hash] params specific to the Store.
      def save_as_association(source, target, *params)
        save_raw_association(@session.id_for!(source), @session.id_for!(target), *params)
      end


      # save an aggregation
      # Aggregation doesn't have necessarily and id
      # therefore we don't use the indentity map.
      # Save objects if needed.
      # Aggregation differs from association in the fact that the 'parent' is already saved
      # and the children have to be saved.
      # @param [id] source_id 
      # @param [Resource] target will be saved.
      # @param [Hash] params specific to the Store.
      def save_as_aggregation(source_id, target, *params)
        save_raw_association(source_id, @session.save(target), *params)
      end

      # Load a model object (and its children) from its database id.
      # @param [Id] id in the database
      # @return [Resource] the model object.
      # @raises error if object doesn't exists.
      def load_single_model(id)
        get_or_create_single_model(id) { load_raw_object(id) }
      end

      def get_or_create_single_model(id, &raw_creator)
        object_for(id) || raw_creator.call().tap do |m|
          map_id_object(id, m)
          load_children(id, m)
          @session.on_object_load(m)
        end
      end

      protected :get_or_create_single_model

      def load_associated_elements()
      end

      def load_aggregated_elements(id, &block)
        load_raw_associations(id).each do |element_id|
        end
      end


      private
      # The primary key 
      # @return [Symbol]
      def primary_key()
        :id
      end

      # load the object without any dependency
      # @param id identifier of the object
      # @return the loaded object
      def load_raw_object(id)
        raise NotImplementedError
      end

      # Called to save a new object, i.e. which is not
      # already in the database.
      # @param [Resource] object the object 
      # @return [Fixnum, nil] the Id if save successful
      def save_new(object, *params)
        save_raw(object, *params).tap do |id|
          save_children(id, object)
        end
      end

      # @param object the object to save
      def save_raw(object, *params)
        raise NotImplementedError
      end

      # Save a object already in the database
      # @param [Resource] object the object 
      # @param [Fixum] id id in the database
      # @return [Fixnum, nil] the Id if save successful.
      def update(object, id, *params)
        # naive version , update everything.
        # Probably quicker than trying to guess what has changed
        id.tap do
          update_raw(object, id, *params)
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
