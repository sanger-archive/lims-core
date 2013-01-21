# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'sequel'
require 'lims/core/persistence'
require 'lims/core/persistence/uuidable'

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
          Uuids::UuidResource::pack(uuid)
        end

        # Unpac if needed an uuid from its store representation
        # @param [Object] puuid
        # @return [String]
        def self.unpack_uuid(puuid)
          Uuids::UuidResource::unpack(puuid)
        end
      end
    end
  end
end
