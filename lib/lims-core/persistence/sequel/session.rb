# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'sequel'
require 'common'
require 'lims-core/persistence'
require 'lims-core/persistence/uuidable'
require 'lims-core/persistence/session'
require 'lims-core/helpers'

module Lims::Core
  module Persistence
    module Sequel
      # Sequel specific implementation of a {Persistence::Session Session}.
      class Session < Persistence::Session
        include Uuidable
        # Pack if needed an uuid to its store representation
        # @param [String] uuid
        # @return [Object]
        def self.pack_uuid(uuid)
          # Normal behavior shoulb be pack to binary data
          UuidResource::pack(uuid)
          #For now, we just compact it.
          UuidResource::compact(uuid)

        end

        # Unpac if needed an uuid from its store representation
        # @param [Object] puuid
        # @return [String]
        def self.unpack_uuid(puuid)
          #UuidResource::unpack(puuid)
          UuidResource::expand(puuid)
        end

        def serialize(object)
          Lims::Core::Helpers::to_json(object)
        end

        def unserialize(object)
          Lims::Core::Helpers::load_json(object)
        end

        def lock(datasets, unlock=false, &block)
          datasets = [datasets] unless datasets.is_a?(Array)
          db = datasets.first.db
          
          # sqlite3 handles lock differently.
          # @TODO create Session Subclass for each database type.
          return lock_for_update(datasets, &block) if db.database_type == :sqlite

          db.run("LOCK TABLES #{datasets.map { |d| "#{d.first_source} WRITE"}.join(",")}")
          block.call(*datasets).tap { db.run("UNLOCK TABLES") if unlock }
        end

        # this method is to be used when the SQL store
        # doesn't support LOCK, which is the case for SQLITE
        # It can be used to redefine lock if needed.
        def lock_for_update(datasets, &block)
          datasets.first.db.transaction do
            block.call(*datasets.map(&:for_update))
          end
        end

        # Return the parameters needed for the creation
        # of a session object. It use session attributes
        # which have been set at contruction time.
        # This allow the same session to be reopen multiple times
        # and create each time a new session with the same parameters.
        # @return [Hash]
        def session_object_parameters
          {:user => @user ,
            :backend_application_id => @backend_application_id,
            :parameters => serialize(@parameters) || nil 
          }
        end

        # Override with_session to create a session object
        # needed by the database to update revision.
        # session object are create from the parameters
        # If the session can't be created due to the lack of parameters.
        # Nothing is created.
        def with_session(*params, &block)
          with_current_session do
            super(*params, &block)
          end
        end

        def with_current_session(&block)
          session_created = false
          if @current_session_id == nil && database.database_type != :sqlite
            @current_session_id = database[:sessions].insert(session_object_parameters)
            session_created = true
          end
          set_current_session_id
          begin
            result = block.call
            success = true
          ensure
            if session_created
              # mark it as finished
              database[:sessions].where(:id => @current_session_id).update(:end_time => DateTime.now, :success => success)
              @current_session_id = nil
              set_current_session_id
            end
          end

          return result
        end

        def set_current_session_id()
          return if database.database_type == :sqlite
          database.run "SET @current_session_id = #{@current_session_id ? @current_session_id : "NULL"};"
          end

          def transaction(&block)
            super do
              # Set the current_session_id again
              # in case it's been overriden by another thread.
              # Solves bug #64570338
              with_current_session(&block)
            end
          end
        end
      end
    end
  end
