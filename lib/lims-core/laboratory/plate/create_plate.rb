# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-core/laboratory/plate'
require 'lims-core/laboratory/container/container'

module Lims::Core
  module Laboratory
    class Plate::CreatePlate
      include Action
      include Container

      # @attribute [Hash<String, Array<Hash>>] wells_description
      # @example
      #   { "A1" => [{ :sample => s1, :quantity => 2}, {:sample => s2}] }
      attribute :wells_description, Hash, :default => {}
      # Type is the actual type of the plate, not the role in the order.
      attribute :type, String, :required => false, :writer => :private 

      def container_class
        Laboratory::Plate
      end

      def element_description
        wells_description
      end

      def container_symbol
        :plate
      end

      def container_parameters
        super.merge(:type => type)
      end
    end
  end

  module Laboratory
    class Plate
      Create = Actions::CreatePlate
    end
  end
end
