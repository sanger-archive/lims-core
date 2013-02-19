require 'lims/core/resource'
require 'lims/core/laboratory/tube'

module Lims::Core
  module Laboratory
    class TubeRack
      include Resource

      is_matrix_of Tube do |p,t|
        Array.new(p.number_of_rows * p.number_of_columns)
      end

      class RackPositionNotEmpty < StandardError
      end

      # Overwrite []= method to add tube in the rack.
      # The value nil needs to be set sometimes, for
      # example when we move physically a tube between
      # racks, the source rack position is then empty.
      # @param [Symbol, String] position in the rack
      # @param [Laboratory::Tube] tube
      def []=(key, value)
        raise ArgumentError, "#{value} is not a Tube" unless value.is_a? Tube or value.nil?

        case key
        when /\A([a-zA-Z])(\d+)\z/
          position = element_name_to_index($1, $2)
          raise RackPositionNotEmpty unless content[position].nil? or value.nil?
          content[position] = value
        when Symbol
          self[key.to_s] = value
        else
          super(key, value)
        end
      end
    end
  end
end
