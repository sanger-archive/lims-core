require 'lims/core/resource'
require 'lims/core/laboratory/receptacle'

require 'facets/hash'
require 'facets/array'

module Lims::Core
  module Laboratory
    class Gel
      include Resource
      %w(row column).each do |w|
        attribute :"number_of_#{w}s", Fixnum, :required => true, :gte => 0, :writer => :private, :initializable => true
      end

      class Window
        include Receptacle
      end

      is_matrix_of Window do |gel, window|
        (gel.number_of_rows*gel.number_of_columns).times.map { window.new }
      end

    end
  end
end