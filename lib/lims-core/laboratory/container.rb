require 'common'

module Lims::Core
  module Laboratory
    # A container is an a laboratory pieces
    # containing other laboratory pieces.
    # Example, a plate or a tube rack.
    module Container
      private
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        # Declare the container using the contained classes
        # Define basic iterators over the contained objects.
        # @todo implement
        def contains(klass)
          # @todo FIXME it doesn't work
          define_method klass.name.snakecase do
            raise NotImplementedError
          end
        end
      end

    end
  end
end
