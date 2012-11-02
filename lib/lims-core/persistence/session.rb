# vi: ts=2:sts=2:et:sw=2

require 'common'
require 'forwardable'

require 'lims/core/persistence/filter'

module Lims::Core
    module  Persistence
      # A session is in charge of restoring and saving object throug the persistence layer.
      # A Session can not normally be created by the end user. It has to be in a Store::with_session
      # block, which acts has a transaction and save/update everything at the end of it.
      # It should also provides an identity map.
      # Session information (user, time) are also associated to the modifications of those objects.
      class Session

        UnmanagedObjectError = Class.new(RuntimeError)

        extend Forwardable
        # param [Store] store the underlying store.
        def initialize(store, *params)
          @store = store
          @objects = Set.new
          @to_delete = Set.new
          @in_session = false
          @saved = Set.new
          @persistor_map = {}
        end

        def_delegators :@store, :database

        # Execute a block and save every 'marked' object
        # in a transaction at the end.
        # @yieldparam [Session] session the created session.
        # @return the value of the block
        def with_session(*params, &block)
          @in_session = true
          to_return = block[self]
          @in_session = false
          save_all
          return to_return
        ensure
          @in_session = false
        end


        # Tell the session to be responsible of an object.
        # The object will be saved at the end of the session.
        # @example
        #   store.with_session do |session|
        #     session << Plate.new
        #   end
        # @param [Persistable] object the object to persist.
        # @return  the object itself.
        def << (object)
          @objects << object
        end

        # save the object in real.
        # To mark an object as 'to save' use the `<<` method
        # Note we can't make this method private because, the persistor
        # need it to save their children. To solve this, we raise an exception if it's inside a sess
        # @return [Boolean]
        def save(object, *options)
          raise RuntimeError, "Can't save object inside a session. Please considere the << method." unless @save_in_progress
          return id_for(object) if @saved.include?(object)
          @saved << object

          persistor_for(object).save(object, *options)
        end

        def method_missing(name, *args, &block)
          begin
            persistor_for(name)
          rescue NameError
            super(name, *args, &block)         
          end 
        end

        # Called by Persistor to inform the session
        # about the loading of an object.
        # MUST be called by persistors creating Resources.
        def on_object_load(object)
          self << object
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
          @objects.include?(object)
        end

        # Mark an object as to be deleted.
        # The corresponding object will be deleted at the end of the session.
        # For most object you don't need to load it to delete it
        # but some needs (to delete the appropriate children).
        # The real delete is made by calling the {delete_in_real} method.
        def delete(object)
          raise UnmanagedObjectError, "can't delete #{object.inspect}" unless managed?(object)
          @to_delete << object
        end

        private
        # save all objects which needs to be
        def save_all()
          @store.transaction do
            @save_in_progress = true # allows saving
            @objects.each do |object|
              if @to_delete.include?(object)
                delete_in_real(object)
              else
                save(object)
              end
            end
            @save_in_progress = false
          end
        end

        # Call to 
        def delete_in_real(object, *options)
          raise RuntimeError, "Can't delete an object inside a session. Please considere the 'delete' method instead." unless @save_in_progress
          return id_for(object) if @saved.include?(object)
          @saved << object

          persistor_for(object).delete(object, *options)
        end

        # Get the persistor corresponding to the object class
        # @param [Resource] object
        # @return [Persistor, nil]
        def persistor_for(object)
          name = persistor_name_for(object)
          @persistor_map[name]  ||= begin 
                                      persistor_class = @store.base_module.constant(name)
                                      raise NameError, "Persistor #{name} not defined for #{@store.base_module.name}" unless persistor_class &&  persistor_class.ancestors.include?(Persistor)
                                      persistor_class.new(self)
                                    end
        end

        public :persistor_for
        # Compute the class name of the persistor corresponding to the argument
        # @param [Resource]
        # @return [String]
        def  persistor_name_for(object)
          case object
          when String then object
          when Symbol then object.to_s
          when Class then object.name.sub(/^Lims::Core::\w+::/, '')
          else persistor_name_for(object.class)
          end.upper_camelcase
        end

      end
    end
end

