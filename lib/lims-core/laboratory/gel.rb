require 'lims/core/resource'
require 'lims/core/laboratory/receptacle'

require 'facets/hash'
require 'facets/array'

module Lims::Core
  module Laboratory
    # Gel is a labware as seen in a laboratory.
    # It has a number of rows and number of columns property.
    # Gel contains Windows and has some readable labels on it (i.e. barcode).
    class Gel
      include Resource

      # The window can contain a receptacle, which is a chemical substance.
      class Window
        include Receptacle
      end

      is_matrix_of Window do |gel, window|
        (gel.number_of_rows*gel.number_of_columns).times.map { window.new }
      end

    end
  end
end