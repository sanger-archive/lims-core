# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims/core/laboratory/flowcell'

module Lims::Core
  module Persistence
    # @abstract
    # Base for all Flowcell persistor.
    # Real implementation classes (e.g. Sequel::Flowcell) should
    # include the suitable persistor.
    class Flowcell
      Model = Laboratory::Flowcell

      # @abstract
      # Base for all Lane persistor.
      # Real implementation classes (e.g. Sequel::Lane) should
      # include the suitable persistor.
      class Lane
        Model = Laboratory::Flowcell::Lane
      end
    end
  end
end
