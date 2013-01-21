require 'lims/core/resource'
require 'lims/core/laboratory/receptacle'

require 'facets/hash'
require 'facets/array'

module Lims::Core
  module Laboratory
    # A plate is a plate as seen in a laboratory, .i.e
    # a rectangular bits of platics with wells and some 
    # readable labels on it.
    # TODO add label behavior
    class Plate 
      include Resource
      %w(row column).each do |w|
        attribute :"number_of_#{w}s", Fixnum, :required => true, :gte => 0, :writer => :private, :initializable => true
      end

      # The well of a {Plate}. 
      # Contains some chemical substances.
      class Well
        include Receptacle
      end

      is_matrix_of Well do |p,t|
        (p.number_of_rows*p.number_of_columns).times.map { t.new }
      end

      # This should be set by the user.
      # We mock it to give pools by column
      # @return [Hash<String, Array<String>] pools pool name => list of wells name
      def pools
        1.upto(number_of_columns).mash do |c|
          [c, 1.upto(number_of_rows).map { |r| indexes_to_element_name(r-1,c-1) } ]
        end
      end
    end
  end
end
