# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'sequel'
require 'lims-core/persistence'
require 'lims-core/persistence/uuidable'
require 'lims-core/persistence/session'
require 'oj'

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
          Oj.dump(object)
        end

        def unserialize(object)
          Oj.load(object)
        end

        def lock(datasets, unlock=false, &block)
          datasets = [datasets] unless datasets.is_a?(Array)
          db = datasets.first.db
          return lock_for_update(datasets, &block) if db.adapter_scheme =~ /sqlite/i

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
      end
    end
  end
end
