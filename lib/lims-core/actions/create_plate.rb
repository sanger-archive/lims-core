# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

module Lims::Core
  module Actions
    class CreatePlate
      include Action

      def initialize(*args, &block)
        @name = "Create Plate"
        super(*args, &block)
      end
    end
  end
end
