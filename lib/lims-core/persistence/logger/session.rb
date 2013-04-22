# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'logger'
require 'lims-core/persistence/session'

module Lims::Core
  module Persistence
    module Logger
      # Logger specific implementation of a {Persistence::Session Session}.
      class Session < Persistence::Session

        attr_reader :indent_level
        def initialize(*args, &block)
          @indent_level = ""
          super(*args, &block)
        end

        def log(msg)
          @store.log(indent_level+msg)
        end

        # Execute a block with the specified indent level indicator.
        # @param [String] indent the indent level indicator
        def with_indent(indent=" - ", &block)
          temporarily('@indent_level' => @indent_level+indent, &block)
        end
      end
    end
  end
end
