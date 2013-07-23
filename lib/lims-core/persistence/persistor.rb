# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/identity_map'


module Lims::Core
  module Persistence
    # @abstract Base class for all the persistors, needs to implements a `self.model`
    # returning the class to persist.
    # A persistor , is used to save and load it's cousin class.
    # The specific code of a persistor should be extended by writting
    # a persistor class within the class to persist and module corresponding to the store.
    # The common Persistor architecture would be like this (let's consider we have a Plate class and a Sequel Persistor).
    # @code
    # module SequelPersistor
    # end
    # Class Plate
    #    Common to all store
    #    class PlatePersistor < Persistence::Persistor
    #    end
    #
    #    class PlateSequelPersistor < PlatePersistor
    #      include SequelPersistor
    #    end
    # end
    # if a base persistor exists for a class but not the store specific one (PlatePersistor exists
    # but PlateSequelPersistor not). If there is a store pecific Persistor module (like SequelPersistor).
    # The equivalent of PlateSequelPersistor will be generated on the fly by deriving the base one and including the mixin.
    # Persistor needs to be registered to be accessible form the session.
    # However, if NO_AUTO_REGISTRATION is not enabled persistors will register themselves. In that case,
    # they will need to be defined in class to persist see {register_model}.
    # If a base peristor for exists for a class but there is no
    # Each instance can get an identity map, and or parameter
    # specific to a session/thread.
    class Persistor

      # Raised if there is any duplicate in the identity maps
      class DuplicateError < RuntimeError 
        def inialize(persistor, value)
          super("${value} already exists for persistor #{persistor.model}")
        end
      end

      #Raised if the `id` is already associated to a different `object`
      class DuplicateIdError <DuplicateError
      end

      #Raised if the `object` is already associated to a different `id`
      class DuplicateObjectError < DuplicateError
      end
      # Performs an autoregistration if needed.
      # Autoregistration can be skipped by defined NO_AUTO_REGISTRATION
      # on the model class.
      # See {Persistor::register_model}.
      def self.inherited(subclass)
        register_model(subclass)
      end

      # Register a sub-persistor to the {Session}.
      # The name used to register the persistor would be
      # either the name of the model (parent) class
      # or if SESSION_NAME is specified on the model : SESSION_NAME
      # @param [Class] subclass
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
          @id_to_state = {}
          @object_to_state = Hash.new { |h,k| h[k] = ResourceState.new(k, self) }
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
          when Fixnum then retrieve(id)
          when Hash then find_by(filter_attributes_on_save(id), :single => true)
          when Array, Enumerable then bulk_retrieve(id)
          end
        end

        # @todo
        def id_for(object)
          state_for(object).andtap { |state| state.id }
        end
        
        def object_for(id)
          @id_to_state[id].andtap(&:resource)
        end


        # @todo
        def state_for(object)
          @object_to_state[object]

        end

        def bind_state_to_id(state)
          raise RuntimeError, 'Invalid state' if state.persistor != self
          raise DuplicateIdError, "#{self.class.name}:#{state.id}" if @id_to_state.include?(state.id)
          @id_to_state[state.id] = state
        end

        # @todo
        def new_state_for_attribute(id, attributes)
          resource = model.new(filter_attributes_on_load(attributes))
          ResourceState.new(resource, self, id)
        end

        # save an object and return is id or nil if failure
        # @return [Fixnum, nil]
        def saveX(object, *params)
          return nil if object.nil?
          # check if the object has been modified or not
          id_for(object) { |id| update(object, id, *params) } ||
          map_id_object(save_new(object, *params) , object)
        end

        # deletes an object and returns its id or nil if failure
        # @return [Fixnum, nil]
        def deleteX(object, *params)
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
        def save_as_associationX(source, target, *params)
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
        def save_as_aggregationX(source_id, target, *params)
          save_raw_association(source_id, @session.save(target), *params)
        end

        # Load a model object (and its children) from its database id.
        # @param [Id] id in the database
        # @param [Hash] raw_attributes attributes to build the object
        # @return [Resource] the model object.
        # @raise error if object doesn't exists.
        def load_single_modelX(id, raw_attributes=nil)
          raw_attributes ||= load_raw_attributes(id)
          model.new(filter_attributes_on_load(raw_attributes) || {}).tap do |m|
            load_children(id, m)
          end
        end
        private :load_single_modelX

        # create or get an object if already in cache
        # The raw_attributes is there for convenience  to
        # create the object with parameters is they have already been loaded
        # (bulk load for example).
        def get_or_create_single_modelX(id, raw_attributes=nil)
          object_for(id) || load_single_model(id, raw_attributes).tap do |m|
            map_id_object(id, m)
            if @session.dirty_attribute_strategy
              dirty_key = @session.dirty_key_for(filter_attributes_on_save(m.attributes))
              @id_to_dirty_key[id]= dirty_key
            end
            @session.on_object_load(m)
          end
        end
        protected :get_or_create_single_modelX

        def dirty_key_for(resource)
            if @session.dirty_attribute_strategy
              @session.dirty_key_for(filter_attributes_on_save(resource.attributes))
            end
        end

        # create or get a list of objects.
        # Only load the ones which aren't in cache
        # @param [Array<Id>] ids list of ids to get
        # @param [Array<Hash>] list of raw_attributes (@see get_or_create_single_model)
        # @return [Array<Resource>]
        # @todo bulk load if needed
        def get_or_create_multi_modelX(ids, raw_attributes_list=[])
          ids.zip(raw_attributes_list).map { |i, r| get_or_create_single_model(i, r) }
        end
        protected :get_or_create_multi_modelX

        # Create or get one or object matching the criteria
        # @param [Hash] criteria, map of (attributes, value) to match
        # @param [Boolean] single wether to check for uniquess or not
        # @return [Object,nil,Array<Object>] an Object or and Array depending of single.
        #
        def find_byM(criteria, single=false)
          ids = ids_for(criteria)

          if single
            raise RuntimeError, "More than one object match the criteria" if ids.size > 1
            return nil if ids.size < 1
            get_or_create_single_model(ids.first)
          else
            get_or_create_multi_model(ids)
          end
        end
        protected :find_byM

        # compute a list of ids matching the criteria
        # @param [Hash] criteria list of attribute/value pais
        # @return [Array<Id>] 
        def ids_for(criteria)
          raise NotImplementedError
        end


        def load_associated_elementsX()
        end

        def load_aggregated_elementsX(id, &block)
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
        def sliceM(start, length)
          Enumerator.new do |yielder|
            for_each_in_slice(start, length) do |id, att|
              yielder << get_or_create_single_model(id, att)
            end
          end
        end

        # Get the next id available id
        # If more than one id are requested, this function will return the last one.
        def get_next_id(number=1)
        end

        # @todo doc
        def bulk_insert(states, *params)
          states.map { |state| insert(state, *params) }
        end

        # @todo doc
        def insert(state, *params)
          #bulk_insert and insert can be both implemented from each other.
          #raise a NotImplementedError is none of them have been implemented
          raise NotImplementedError if @__simple_insert
          @__simple_insert = true
          bulk_insert([state], *params).tap do
            @__simple_insert = false
          end
        end

        def bulk_retrieve(ids, *params)
          # we need to separate object which need to be loaded
          # from the one which are already in cache
          to_load = ids.reject { |id| id == nil || @id_to_state.include?(id) }
          bulk_load_raw_attributes(to_load, *params).each do |att|
            id = att.delete(primary_key)
            new_state_for_attribute(id, att).resource
          end

          ids.map { |id| object_for(id) }
        end

        def retrieve(id, *params)
          objects = bulk_retrieve([id], *params)
          objects.size == 1 ? object.first : nil
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
        def load_raw_objectX(id)
          raise NotImplementedError
        end

        # Called to save a new object, i.e. which is not
        # already in the database.
        # @param [Resource] object the object 
        # @return [Fixnum, nil] the Id if save successful
        def save_newM(object, *params)
          save_raw(object, *params).tap do |id|
            save_children(id, object)
          end
        end

        # Save a object already in the database
        # @param [Resource] object the object 
        # @param [Fixum] id id in the database
        # @return [Fixnum, nil] the Id if save successful.
        def updateX(object, id, *params)
          # Check if 
          # naive version , update everything.
          # Probably quicker than trying to guess what has changed
          id.tap do
            if dirty?(object, id)
              update_raw(object, id, *params)
            end  
            update_children(id, object)
          end
        end

        # Check if an item is dirty and update
        # its dirty key
        # @param[Resource] object
        # @param[Fixum] id 
        # @return [Bool] true if the object is dirty (needs saving)
        def dirtyM?(object, id, *params)
            attributes = filter_attributes_on_save(object.attributes, *params)
            # check if the object is dirty on note.
            # In fact, we only cares about the attributes
            # because a dirty attribute which is not saved doesn't really matter
            if @session.dirty_attribute_strategy
              old_dirty_key = @id_to_dirty_key[id]
              new_dirty_key = @session.dirty_key_for(attributes)

              @id_to_dirty_key[id] = new_dirty_key
              !(old_dirty_key && old_dirty_key == new_dirty_key)
            else
              true
            end
        end

        def delete_rawX(object, id)
          raise NotImplementedError
        end

        # save children of a newly created object.
        # @param [Fixum] id id in the database
        # @param [Resource] object the object 
        def save_childrenX(id, object)

        end

        # save children of an existing object.
        # @param [Fixum] id id in the database
        # @param [Resource] object the object 
        def update_childrenX(id, object)
          delete_children(id, object)
          save_children(id, object)
        end

        def delete_childrenX(id, object)
        end

        # Loads children from the database and set the to model object.
        # @param id primary key of the model object in the database.
        # @param m  instance of model to load
        def load_childrenX(id, m)
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
require 'lims-core/persistence/session'
