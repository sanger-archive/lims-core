# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims/core/laboratory/flowcell'

module Lims::Core
  module Persistence
    # @abstract
    # Base for all Plate persistor.
    # Real implementation classes (e.g. Sequel::Plate) should
    # include the suitable persistor.
    class Plate
      Model = Laboratory::Plate

      # @abstract
      # Base for all Well persistor.
      # Real implementation classes (e.g. Sequel::Well) should
      # include the suitable persistor.
      class Well
        Model = Laboratory::Plate::Well
      end
    end
  end
end
