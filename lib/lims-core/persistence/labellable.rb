require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/labellable'

# needs to require all label subclasses
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  module Persistence
    class Labellable < Persistor
      Model = Laboratory::Labellable

      def label
        @session.send("Labellable::Label")
      end

      # Saves all children of a given Labellable
      def save_children(id, labellable)
        labellable.each do |position, label_object|
          label.save(label_object, id, position)
        end
      end

      # Loads all children of a given Labellable
      def load_children(id, labellable)
        label.load(id) do |position, label|
          labellable[position]=label
        end
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


      class Label < Persistor
        Model = Laboratory::Labellable::Label
      end
    end
  end
end
