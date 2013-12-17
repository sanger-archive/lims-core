# vi: ts=2:sts=2:et:sw=2

require 'common'
require 'forwardable'
require 'digest/md5'

require 'lims-core/persistence/filter'
require 'lims-core/persistence/identity_map'
require 'lims-core/persistence/state_list'
require 'lims-core/helpers'

module Lims::Core
  module  Persistence
    # A session is in charge of restoring and saving object throug the persistence layer.
    # A Session can not normally be created by the end user. It has to be in a Store::with_session
    # block, which acts has a transaction and save/update everything at the end of it.
    # It should also provides an identity map.
    # Session information (user, time) are also associated to the modifications of those objects.
    class Session

      # The dirty-attribute strategy decides
      # how object modification is detected
      # to avoid saved unmodified object.
      # The default value comes from the session.
      attr_accessor :dirty_attribute_strategy
      class UnmanagedObjectError < RuntimeError
      end

      # The map name <=> model class is shared between all type of session
      #
      def self.model_map()
        @@model_map ||= IdentityMap::Class.new
      end
      # The map of peristor classes depends of the session type (sequel, log, etc ..)
      # As they will be different classes


      extend Forwardable
      # param [Store] store the underlying store.
      def initialize(store, *params)
        @store = store
        @object_states = StateList.new
        @in_session = false
        @saved = Set.new
        @persistor_map = {}
        @dirty_attribute_strategy = @store.dirty_attribute_strategy

        
        options = params.extract_options!
        @user ||= options[:user]
        @application_id ||= options[:application_id]
        @parameters ||= options[:parameters]
      end


      def_delegators :@store, :database

      # Execute a block and save every 'marked' object
      # in a transaction at the End.
      # @yieldparam [Session] session the created session.
      # @return the value of the block
      def with_session(*params, &block)
        return block[self] if @in_session
        begin
          @in_session = true
          to_return = block[self]
          @in_session = false
          save_all
          return to_return
        ensure
          @in_session = false
        end
      end
      # Subsession allow to create a session
      # within a session sharing the same persistor
      # but saving only the object managed by the subsession.
      # The current implementation doesn't create new session
      # but just push some session attributes.
      # The problem about creating a new Session, we want them 
      # to share ResourceState, but a state own a persistor which in
      # turn own a session, so it's easier if the session is the same.
      def with_subsession(*params, &block)
        backup = [@object_states, @in_session, @saved]
        @object_states = StateList.new
        @in_session = false
        @saved = Set.new

        return_value = with_session(*params, &block)
        
        @object_states, @in_session, @saved = backup

        return_value
      end


      # Tell the session to be responsible of an object.
      # The object will be saved at the end of the session.
      # @example
      #   store.with_session do |session|
      #     session << Plate.new
      #   end
      # @param [Persistable] object the object to persist.
      # @return  the session, to allow for chaining
      def << (object)
        manage_state(state_for(object))
        self
      end

      def manage_state(state)
        @object_states << state
      end

      def method_missing(name, *args, &block)
        begin
          persistor_for(name)
        rescue NameError
          # No persistor found for the given name
          # Call the normal method_missing
          super(name, *args, &block)
        end
      end


      # Returns the id of an object if exists.
      # @param [Resource, Id] object or id.
      # @return [Id, nil]
      def id_for(object)
        case object
        when Resource then persistor_for(object).id_for(object)
        else object # the object should be already an id
        end
      end

      # Get or creates the ResourceState corresponding to an object.
      # @param [Resource] object
      # @return [ResourceState]
      def state_for(object)
        return persistor_for(object).state_for(object)
      end

      def states_for(objects)
        objects && objects.map { |o| state_for(o) }
      end



      # Returns the id of an object and save it if necessary
      # @param [Resource, Id] object or id.
      # @return [Id]
      def id_for!(object)
        return nil unless object
        id_for(object) || save(object)
      end

      # Check if the session 'mananage' already this object.
      # .i.e if it's been loaded or meant to be saved
      # @param [Resource] object
      # @return [Boolean]
      def managed?(object)
        persistor_for(object).state_for?(object)
      end

      # Mark an object as to be deleted.
      # The corresponding object will be deleted at the end of the session.
      # For most object you don't need to load it to delete it
      # but some needs (to delete the appropriate children).
      # The real delete is made by calling the {#delete_in_real} method.
      def delete(object)
        raise UnmanagedObjectError, "can't delete #{object.inspect}" unless managed?(object)
        state = state_for(object)
        state.mark_for_deletion
      end

      # Pack if needed an uuid to its store representation
      # This method is need to lookup an uuid by name
      # @param [String] uuid
      # @return [Object]
      def self.pack_uuid(uuid)
        uuid
      end

      def pack_uuid(uuid)
        self.class.pack_uuid(uuid)
      end

      # Unpac if needed an uuid from its store representation
      # @param [Object] puuid
      # @return [String]
      def self.unpack_uuid(puuid)
        puuid
      end

      def unpack_uuid(uuid)
        self.class.unpack_uuid(uuid)
      end

      # @todo doc
      def serialize(object)
        object
      end

      def unserialize(object)
        object
      end

      def dirty_key_for(object)
        case @dirty_attribute_strategy
        when Store::DIRTY_ATTRIBUTE_STRATEGY_DEEP_COPY then object
        when Store::DIRTY_ATTRIBUTE_STRATEGY_SHA1 then Digest::SHA1.hexdigest(Lims::Core::Helpers::to_json(object))
        when Store::DIRTY_ATTRIBUTE_STRATEGY_MD5 then Digest::MD5.hexdigest(Lims::Core::Helpers::to_json(object))
        when Store::DIRTY_ATTRIBUTE_STRATEGY_QUICK_HASH then object.hash
        end
      end

      private
      # save all objects which needs to be
      def save_all()
        @store.transaction do
          @save_in_progress = true # allows saving
          @object_states.reset_status
          @object_states.save
          end
        @save_in_progress = false
      end

      # Create a new persistor sharing the same internal parameters
      # but with the "context" (datasest) of the new one.
      # This can be used to "reset" a filtered persistor to the current session.
      # @param [Persistor] persistor
      # @return [Persistor]
      def filter(persistor)
        # If the persistor session is the current session, there is nothing to do
        # just return the object as it is.
        return persistor if  persistor.instance_eval {@session} == self

        # we need first to find the original persistor, ie the one  that the user can call via
        # session.model
        original = persistor_for(persistor.class)
        persistor.class.new(original, persistor.dataset)
      end

      # Find the model class for a registered name
      # registered name are used when doing session.model
      # @param [String, Symbol] name
      # @return [Class]
      def self.name_to_model(name)
        model_map.object_for(name.to_s)
      end

      # Find the registered name of a given class
      # @param[Class] model
      # @return [Symbol]
      def self.model_to_name(model)
        model_map.id_for(model)
      end

      # Register a model for a given name.
      # This name will be looked up when calling session.<name>
      # Persistors need to be registered.
      # @param [String, Symbol] name
      # @param [Class] model
      def self.register_model(name, model)
        name = name.to_s.snakecase
        # skip if name already registered with the same object
        return if model_map.object_for(name) == model
        model_map.map_id_object(name, model)
      end


      # Find the model corresponding to an object
      # Takes many type of input
      # @param [String, Symbol, Resource, Persistor] object
      # @return [Symbol]
      def  self.model_for(object)
        case object
        when nil then nil
        when String then name_to_model(object)
        when Symbol then name_to_model(object)
        when Class then
          # check if the class has been registered
          # IMPORTANT needs to be done before 'when module'
          # because object can class and module at the same time.
          return object if model_to_name(object)

          # if it's already persistor find the associate model
          persistor_class_map.id_for(object) do |model|
            return model
          end



          # check the super class
          model_for(object.superclass).andtap { |model|
            return model
          }

          # Check the owner
          return nil unless object.respond_to? :parent_scope
          model_for(object.parent_scope).andtap { |model|
            return model
          }
        when Module then object
        else
          model_for(object.class)
        end
      end

      def self.persistor_name_for(object)
        model = model_for(object)
        model_to_name(model)
      end

      def persistor_name_for(object)
        self.class.persistor_name_for(object)
      end

      # @param [String, Symbol, Resource, Persistor] object
      # @return [Class]
      def self.persistor_class_for(object)
        model = model_for(object)

        persistor = persistor_class_map.object_for(model)
        unless persistor
        persistor = find_or_create_persistor_for(model)
        persistor_class_map.map_id_object(model, persistor)
        end
        persistor
      end

      def self.persistor_class_map()
        @persistor_class_map ||= IdentityMap::Class.new
      end

      def self.find_or_create_persistor_for(model)
        # find the persistor within the class
        # other corresponding to the current session type
        return nil unless model
        session_persistor_class = parent_scope.const_get(:Persistor)
        model.constants(false).each do |name|
          klass = model.const_get(name)
          next unless klass.is_a? Module
          if  klass.ancestors.include?(session_persistor_class)
            # quick hack  to fix JRuby test before refactoring this
            # If we are not in a sequel session, we need to not pick the Seque persistor.
            next if session_persistor_class.name !~ /sequel/i && klass.name =~ /sequel/i
            # found
            return klass
          end
        end
        # not found, we need to create it
        # First we look for the base persistor to inherit from
        #debugger unless superclass.respond_to? :persistor_class_for
        raise "Can't find base persistor for #{model.inspect}"  unless superclass.respond_to? :persistor_class_for
         
        parent_persistor_class = superclass.persistor_class_for(model)

        # if the current persistor (ex Sequel::Persistor) is the same  as the base one
        # there is nothing else to do
        return parent_persistor_class unless parent_scope::const_defined?(:Persistor, false)

        raise  "no Persistor defined for #{model.name}" unless parent_persistor_class
        module_name = parent_scope.name.sub(/.*Persistence::/,'')
        model_name = model.name.split('::').pop
        # the we create a new Persistor class including the Persistor mixin
        # corresponding to the session
        class_declaration = <<-EOV
        class #{model_name}#{module_name}Persistor < #{parent_persistor_class.name}
          include #{parent_scope::Persistor}
        end
        EOV
        model.class_eval class_declaration

      end


      # Get the persistor corresponding to the object class
      # @param [Resource, String, Symbol, Persistor] object
      # @return [Persistor, nil]
      def persistor_for(object)
        if object.is_a?(Persistor)
          return filter(object)
        end

        model = self.class.model_for(object)
        @persistor_map[model]  ||= begin
          persistor_class = self.class.persistor_class_for(model)
          raise NameError, "no persistor defined for #{object.class.name}" unless persistor_class &&  persistor_class.ancestors.include?(Persistor)
          persistor_class.new(self)
        end
      end


      public :persistor_for
      # Compute the class name of the persistor corresponding to the argument
      # @param [Resource, String, Symbol] object
      # @return [String]
    end
  end
end

require 'lims-core/persistence/uuid_resource_persistor'
