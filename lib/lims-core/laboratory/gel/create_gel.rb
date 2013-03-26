require 'lims-core/actions/action'

require 'lims-core/laboratory/gel'
require 'lims-core/laboratory/container/container'

module Lims::Core
  module Laboratory
    class Gel::CreateGel
      include Action
      include Container

      # @attribute [Hash<String, Array<Hash>>] windows_description
      # @example
      #   { "A1" => [{ :sample => s1, :quantity => 2}, {:sample => s2}] }
      attribute :windows_description, Hash, :default => {}

      def container_class
        Laboratory::Gel
      end

      def element_description
        windows_description
      end

      def container_symbol
        :gel
      end
    end
  end

  module Laboratory
    class Gel
      Create = Actions::CreateGel
    end
  end
end
