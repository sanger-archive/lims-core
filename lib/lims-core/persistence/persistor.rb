# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/persistor_module'
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
    # * Methods relative to store  are
    # - insert : a new object to the store
    # - delete : remove an object fromt the store
    # - update : modify an existing object from the store.
    # - retrieve : get an object from the store.
    # - bulk_<method> vs <method> refers to method acting on a list of states 
    # instead of an individual object. Althoug only one version needs to be implemted
    # , the bulk version is prefered for performance reason.
    # - raw_<method_ refers when exists to the physical action done to the store
    # without any side effect on the Session or Persistor. They should not normally be called.
    # * Methods relative to parents/children
    # - parents : resources needed to be saved BEFORE the resource itself.
    # - children : resources needed to be save AFTER the resource itself.
    # - deletable_children : resources which needs to be deleted BEFORE the resource itself.
    # - deletable_parent : resources which needs to be deleted AFTER the resource itself.
    class Persistor

      # Raised if there is any duplicate in the identity maps
      class DuplicateError < RuntimeError 
        def initialize(persistor, value)
          super("#{value.inspect} already exists for persistor #{persistor.model}")
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
          @id_to_state = Hash.new { |h,k| h[k] = ResourceState.new(nil, self, k) }
          @object_to_state = Hash.new { |h,k| h[k] = ResourceState.new(k, self) }
          @@persistor_module_map ||= {}
          setup_persistor_modules
          super(*args, &block)
        end

        # For each persistor modules found, we extend the current
        # persistor with them.
        def setup_persistor_modules
          model_name = @session.class.model_to_name(model)
          persistor_modules_for(model_name).each do |persistor_module|
            self.extend(persistor_module)
          end
        end

        def self.persistor_module_map
          @@persistor_module_map
        end

        # @param [String] model
        # @return [Array<PersistorModule>]
        # Return all the persistor modules which are eligible to extend 
        # the <model> persistors.
        def persistor_modules_for(model)
          @@persistor_module_map[model] ||= begin 
            Persistence::PersistorModule.constants.map do |module_symbol|
              Persistence::PersistorModule.const_get(module_symbol)
            end.select do |persistor_module|
              persistor_module::defined_for?(model)
            end
          end
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
        # @param [Boolean] single or list of object to return
        # @return [Object,nil] nil if  object not found.
        def [](id, single=true)
          case id
          when Fixnum then retrieve(id)
          when Hash then find_by(filter_attributes_on_save(id), single)
          when Array, Enumerable then bulk_retrieve(id)
          end
        end

        # Get the id from an object from the cache.
        # @param [Resource] object object to find the id for.
        # @return [Id, Nil]
        def id_for(object)
          state_for(object).andtap { |state| state.id }
        end
        
        # Get the object from a given id.
        # @param [Fixnum] id
        # @return [Resourec, Nil]
        def object_for(id)
          @id_to_state[id].andtap(&:resource)
        end


        # Returns the state proxy of an object.
        # Creates it if needed.
        # @param [Resource] object
        # @return [ResourceState]
        def state_for(object)
          @object_to_state[object]
        end

        # Returns the state proxy of an object fromt its id (in cache).
        # Creates the state if needed.
        # @param [Id] object
        # @return [ResourceState]
        def state_for_id(id)
            @id_to_state[id]
        end

        # Updates the cache so id_to_state
        # reflects state.id
        # @param [ResourceState]
        def bind_state_to_id(state)
          raise RuntimeError, 'Invalid state' if state.persistor != self
          raise DuplicateIdError.new(self, state.id)if @id_to_state.include?(state.id)
          on_object_load(state)
          @id_to_state[state.id] = state
        end

        # Called by Persistor to inform the session
        # about the loading of an object.
        # MUST be called by persistors creating Resources.
        # @param [ResourceState]
        def on_object_load(state)
          @session.manage_state(state)
        end

        # Update the cache 
        def bind_state_to_resource(state)
          raise RuntimeError, 'Invalobject state' if state.persistor != self
          raise DuplicateIdError.new(self, state.resource) if @object_to_state.include?(state.resource)
          @object_to_state[state.resource] = state
        end

        # Creates a new object from a Hash and associate it to its id
        # @param [Id] id id of the new object
        # @param [Hash] attributes of the new object.
        # @return [Resource]
        def new_object(id, attributes)
          id = attributes.delete(primary_key)
          model.new(filter_attributes_on_load(attributes)).tap do |resource|
            state = state_for_id(id)
            state.resource = resource
          end
        end

        # Computes "dirty_key" of an object.
        # The dirty key is used to decide if an object
        # has been modified or not.
        # @param [ Resource]
        # @return [Object]
        def dirty_key_for(resource)
            if resource && @session.dirty_attribute_strategy
              @session.dirty_key_for(filter_attributes_on_save(resource.attributes_for_dirty))
            end
        end

      # Delete all invalid object loaded by a persistor.
      # Typically invalid object are association which doesn't exist anymore
      def purge_invalid_object
        to_delete = StateGroup.new(self, [])
        @object_to_state.each do |object, state|
          to_delete << state if  invalid_resource?(object)
        end

        to_delete.destroy
      end

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
            self[ids].first
          else
            self[ids]
          end
        end
        protected :find_by

        # compute a list of ids matching the criteria
        # @param [Hash] criteria list of attribute/value pais
        # @return [Array<Id>] 
        def ids_for(criteria)
          raise NotImplementedError
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
          to_load = StateGroup.new(self, [])
            for_each_in_slice(start, length) do |att|
              to_load << new_from_attributes(att)
            end
          to_load.load.map(&:resource)
        end

        # Inserts objects in the underlying store AND manages them.
        # This method only care about the objects themselves not about
        # theirs parents or children.
        # The physical insert in the store must be  specified for each store.
        def bulk_insert(states, *params)
          states.map { |state| insert(state, *params) }
        end

        # Remove object form the underlying store and Manages them.
        # This method only care about the objects themselves not about
        # theirs parents or children.
        def bulk_delete(states, *params)
          # delete theme but leave them in cache
          # in case they need to be displayed.
          states.each do |state|
            state.id.andtap { |id| @id_to_state.delete(id) }
            state.resource #.andtap { |object| @object_to_state.delete(object) }
          end
          bulk_delete_raw(states.map(&:id).compact, *params)
        end

        # @abstract
        # Physically remove objects from a store.
        def bulk_delete_raw(states, *params)
          raise NotImplementedError
        end

        %w(insert update delete_raw).each do |method|
          class_eval %Q{
          #bulk_#{method} and #{method} can be both implemented from each other.
          #raise a NotImplementedError is none of them have been implemented
        def #{method}(param, *params)
          raise NotImplementedError if @__simple_#{method}
          @__simple_#{method} = true
          bulk_#{method}([param], *params).andtap do |results|
            @__simple_#{method} = false
            results.first
          end
        end
      }
      end

      # Retrieves an object from it's id.
      # Doesn't load it if it's been alreday loaded.
      # @param [Id] id
      # @return [Object, nil]
      def retrieve(id, *params)
        object_for(id).andtap { |o| return o }
        objects = bulk_retrieve([id], *params)
        return objects.first if objects && objects.size == 1

      end

      # Retreives a list of objects .
      # @param[Array<Id>] ids
      # @return [Array<Object]
        def bulk_retrieve(ids, *params)
          # create a list of states and load them
          states = StateGroup.new(self, ids.map do |id|
            @id_to_state[id]
          end)

          states.load
          return StateList.new(states.map { |state| state.resource })

          # we need to separate object which need to be loaded
          # from the one which are already in cache
          to_load = ids.reject { |id| id == nil || @id_to_state.include?(id) }
          loaded_states = bulk_load_raw_attributes(to_load, *params) do |att|
            id = att.delete(primary_key)
            new_state_for_attribute(id, att).resource
          end

          bulk_retrieve_children(new_states, *params)
          #bulk_retrieve_parent(new_states, *params)


          ids.map { |id| object_for(id) }
        end

        # Updates the store and manages object.
        # Doesn't care of children or parents.
        # @param [Array<ResourceState] states
        def bulk_update(states, *params)
          attributes = states.map do |state|
            filter_attributes_on_save(state.resource.attributes).merge(primary_key => state.id)
          end
          bulk_update_raw_attributes(attributes, *params)
          states.each do |state|
            state.updated
          end
        end

        %w(parents children deletable_children deletable_parents).each do |m|
          # @method #{m}_for
          # @param [Resource]
          # @return [Array<ResourceState>]
          define_method "#{m}_for" do |resource|
            @session.states_for(public_send(m, resource))
          end
        end

        # List of parents of object, i.e. object which need to be saved BEFORE it.
        # Default implementation get all Resource attributes.
        # @param [Resource]  resource
        # @return [Array<Resource>]
        def parents(resource)
          resource.attributes.values.select  { |v| v.is_a? Resource }
        end

        # List of children , i.e, object which need to be saved AFTER it.
        # @param [Resource]  resource
        # @return [Array<Resource>]
        def children(resource)
          []
        end

        # @todo
        def deletable_children(resource)
          []
        end

        def deletable_parents(resource)
          []
        end

        # if a resource is invalid and need to be deleted.
        # For example an association proxy corresponding
        # to an old relation.
        def invalid_resource?(resource)
          resource.respond_to?(:invalid?) && resource.invalid?
        end



        protected
        # The primary key 
        # @return [Symbol]
        def primary_key()
          :id
        end

        # Transform  store fields to object attributes
        # This can be used to change the name of an attribute (its key)
        # or its value or both (example resource to resource_id)
        # This is the reverse of {#filter_attributes_on_save}
        # @param [Hash] attributes
        # @return [Hash]
        def filter_attributes_on_load(attributes)
          if block_given?
            attributes.mash do |k,v|
              yield(k,v) || [k,v]
            end
          else attributes
          end
        end

        def parents_for_attributes(attributes)
          []
        end

        public :parents_for_attributes
        def load_children(states, *params)
          []
        end
        public :load_children

        def new_from_attributes(attributes)
          id = attributes.delete(primary_key)
          resource = block_given? ? yield(attributes) :   model.new(filter_attributes_on_load(attributes))
          state_for_id(id).tap { |state| state.resource = resource }
        end
        public :new_from_attributes

        # Transform object attributes to store fields
        # This can be used to change the name of an attribute (its key)
        # or its value or both (example resource to resource_id)
        # @param [Hash] attributes
        # @return [Hash]
        def filter_attributes_on_save(attributes)
          attributes.mash do |k, v|
            if block_given?
              result = yield(k,v)
              next result if result
            end
            key = attribute_for(k)
            if key && key != k
              [key, @session.id_for(v) ]
            else
              [k, v]
            end
          end
        end


        def attribute_for(key)
          key
        end

        def self.association_class(association, &block) 
          snake = association.snakecase
          association_class = class_eval  <<-EOC
          class #{association}
            include  Lims::Core::Resource
          end

          def #{snake}
            @session.#{snake}_persistor
          end
          #{association}
          EOC
          association_class.class_eval(&block)
          association_class.class_eval do
            does "lims/core/persistence/persist_association", self
          end
          association_class

        end
      end
    end
  end
  require 'lims-core/persistence/session'
