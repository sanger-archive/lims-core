require 'lims/core/resource'
require 'lims/core/laboratory/container'
require 'lims/core/laboratory/tube'

module Lims::Core
  module Laboratory
    class TubeRack
      include Resource
      %w(row column).each do |w|
        attribute :"number_of_#{w}s", Fixnum, :required => true, :gte => 0, :writer => :private, :initializable => true
      end

      is_array_of Tube do |p,t|
        Array.new(p.number_of_rows * p.number_of_columns)
      end
      include Container

      # Overwrite []= method to add tube in the rack.
      # @param [Symbol, String] position in the rack
      # @param [Laboratory::Tube] tube
      def []=(key, value)
        raise ArgumentError, "#{value} is not a Tube" unless value.is_a? Tube

        case key
        when /\A([a-zA-Z])(\d+)\z/
          row = $1.ord - ?A.ord
          col = $2.to_i - 1
          raise IndexOutOfRangeError unless (0...number_of_rows).include?(row)
          raise IndexOutOfRangeError unless (0...number_of_columns).include?(col)
          content[row * number_of_columns + col] =  value
        when Symbol
          self[key.to_s] = value
        else
          super(key, value)
        end
      end
    end
  end
end
