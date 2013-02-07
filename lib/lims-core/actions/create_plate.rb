# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/laboratory/plate'
require 'lims/core/actions/container'

module Lims::Core
  module Actions
    class CreatePlate
      include Action
      include Container

      # @attribute [Hash<String, Array<Hash>>] wells_description
      # @example
      #   { "A1" => [{ :sample => s1, :quantity => 2}, {:sample => s2}] }
      attribute :wells_description, Hash, :default => {}

      def getContainer
        Laboratory::Plate
      end

      def element_description
        wells_description
      end

      def container_sym
        :plate
      end
    end
  end

  module Laboratory
    class Plate
      Create = Actions::CreatePlate
    end
  end
end
