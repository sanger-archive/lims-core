# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/identity_map'


module Lims::Core
  module Persistence
    # @abstract Base class for all the persistors, needs to implements a `self.model`
    # returning the class to persist.
    # A persistor , is used to save and load it's cousin class.
    # The specific code of a persistor should be extended by writting
    # a persistor module in the sub-persistence module. This module will be 
    # automatically included to generated class. See {Persistence.finalize_submodule}.
    # Each instance can get an identity map, and or parameter
    # specific to a session/thread.
    class Persistor
      include IdentityMap

      # Performs an autoregistration if needed
      def self.inherited(subclass)
        register_model(subclass)
      end

      def self.register_model(subclass)
        model = subclass.parent_scope
        return if model::const_defined? :NO_AUTO_REGISTRATION

        name  =\
          if model::const_defined? :SESSION_NAME 
            model::SESSION_NAME
          else
            name = model.name.split('::').pop
          end

          Session::register_model(name, model)
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

        # Load a model by different criteria. Could be either :
        # - an Id
        # - a Hash 
        # - a list of Ids
        # This method will return either a single object or a list of object,
        # depending of the parameter.
        # Note that loaded object are automatically _added_ to the session.
        # @param [Fixnum, Hash] id the id in the database
        # @return [Object,nil] nil if  object not found.
        def [](id)
          case id
          when Fixnum then get_or_create_single_model(id)
          when Hash then find_by(filter_attributes_on_save(id), :single => true)
          end
        end

        # save an object and return is id or nil if failure
        # @return [Fixnum, nil]
        def save(object, *params)
          return nil if object.nil?
          id_for(object) { |id| update(object, id, *params) } ||
          map_id_object(save_new(object, *params) , object)
        end

        # deletes an object and returns its id or nil if failure
        # @return [Fixnum, nil]
        def delete(object, *params)
          return nil if object.nil?
          id_for(object) do |id|
            # We need to delet the children before the parent
            # to not break any constraints
            delete_children(id, object)
            delete_raw(object, id, *params)
          end
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
        # @param [Hash] raw_attributes attributes to build the object
        # @return [Resource] the model object.
        # @raise error if object doesn't exists.
        def load_single_model(id, raw_attributes=nil)
          raw_attributes ||= load_raw_attributes(id)
          model.new(filter_attributes_on_load(raw_attributes) || {}).tap do |m|
            load_children(id, m)
          end
        end
        private :load_single_model

        # create or get an object if already in cache
        # The raw_attributes is there for convenience  to
        # create the object with parameters is they have already been loaded
        # (bulk load for example).
        def get_or_create_single_model(id, raw_attributes=nil)
          object_for(id) || load_single_model(id, raw_attributes).tap do |m|
            map_id_object(id, m)
            @session.on_object_load(m)
          end
        end
        protected :get_or_create_single_model

        # create or get a list of objects.
        # Only load the ones which aren't in cache
        # @param [Array<Id>] ids list of ids to get
        # @param [Array<Hash>] list of raw_attributes (@see get_or_create_single_model)
        # @return [Array<Resource>]
        # @todo bulk load if needed
        def get_or_create_multi_model(ids, raw_attributes_list=[])
          ids.zip(raw_attributes_list).map { |i, r| get_or_create_single_model(i, r) }
        end
        protected :get_or_create_multi_model

        # Create or get one or object matching the criteria
        # @param [Hash] criteria, map of (attributes, value) to match
        # @param [Boolean] single wether to check for uniquess or not
        # @return [Object,nil,Array<Object>] an Object or and Array depending of single.
        #
        def find_by(criteria, single=false)
          ids = ids_for(criteria)

          if single
            raise RuntimeError, "More than one object match the criteria" if ids.size > 1
            return nil if ids.size < 1
            get_or_create_single_model(ids.first)
          else
            get_or_create_multi_model(ids)
          end
        end
        protected :find_by

        # compute a list of ids matching the criteria
        # @param [Hash] criteria list of attribute/value pais
        # @return [Array<Id>] 
        def ids_for(criteria)
          raise NotImplementedError
        end


        def load_associated_elements()
        end

        def load_aggregated_elements(id, &block)
          load_raw_associations(id).each do |element_id|
          end
        end

        # @abstract
        # Returns the number of object in the store
        # @return [Fixnum]
        def count
          raise NotImplementedError
        end

        # @abstract
        # Load a slice. Doesn't return an object but a hash
        # allowing to build it.
        # @param [Fixnum] start (0 based)
        # @param [Fixnum] length
        # @yieldparam [Fixnum] key
        # @yieldparam [Hash] attributes of the object
        def for_each_in_slice(start, length)
          raise NotImplementedError
        end

        # Get a slice of object by offset, length.
        # +start+ here is an offset (starting at 0) not an Id.
        # @param [Fixnum] start (0 based)
        # @param [Fixnum] length
        # @return [Enumerable<Hash>]
        def slice(start, length)
          Enumerator.new do |yielder|
            for_each_in_slice(start, length) do |id, att|
              yielder << get_or_create_single_model(id, att)
            end
          end
        end

        protected
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

        def delete_raw(object, id)
          raise NotImplementedError
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

        # Transform  store fields to object attributes
        # This can be used to change the name of an attribute (its key)
        # or its value or both (example resource to resource_id)
        # This is the reverse of {#filter_attributes_on_save}
        # @param [Hash] attributes
        # @return [Hash]
        def filter_attributes_on_load(attributes)
          attributes
        end

        # Transform object attributes to store fields
        # This can be used to change the name of an attribute (its key)
        # or its value or both (example resource to resource_id)
        # @param [Hash] attributes
        # @return [Hash]
        def filter_attributes_on_save(attributes)
          attributes
        end

      end
    end
  end
