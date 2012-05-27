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
        attribute :"#{w}_number",  Fixnum, :required => true, :gte => 0, :writer => :private
      end

      # The well of a {Plate}. 
      # Contains some chemical substances.
      class Well
        include Receptacle

        #@todo move into Receptacle
        def to_s()
          content.to_s
        end
      end # class Well

      IndexOutOfRangeError = Class.new(RuntimeError)

      module AccessibleViaSuper
      # @todo move in class method in resource
        def initialize(*args, &block)
          # readonly attributes are normaly not allowed in constructor
          # by Virtus. We need to call set_attributes explicitely
          options = args.extract_options!
          # we would use `options & [:row ... ]` if we could
          # but Sequel redefine Hash#& ...
          dimensions = options.subset([:row_number ,:column_number])
          set_attributes(dimensions)
          super(*args, options - dimensions, &block)
        end

        def [](index)
          case index
          when Array
            get_well(*index)
          when /\A([a-zA-Z])(\d+)\z/
            row = $1.ord - ?A.ord
            col = $2.to_i - 1
            get_well(row, col)
            # why not something like
            # get_well(*[$1, $2].zip(%w{A 1}).map { |a,b| [a,b].map(&:ord).inject { |x,y| x-y } })
          when Symbol
            self[index.to_s]
          else
            super(index)
          end
        end
      end
      # We need to do that so is_array can call it via super
      include AccessibleViaSuper

      is_array_of Well do |p,t|
        (p.row_number*p.column_number).times.map { t.new }
      end

      # Hash behavior

      # Provides the list of the well names, equivalent to
      # the Hash#keys methods.
      # @return [Array<String>]
      def keys
        0.upto(size-1).map { |i| index_to_well_name(i) }
      end

      # List of the wells, equivalent to Hash#values
      def values
        @content
      end

      # each is already defined to look like an Array.
      # This one provide a "String" index (like "A1") aka
      # well name. It ca be used to access the Plate.
      def each_with_index
        @content.each_with_index do |well, index|
          yield well, index_to_well_name(index)
        end
      end
      # return a well from a 2D index
      # Also check the boundary
      # @param [Fixnum] row index of the row (starting at 0)
      # @param [Fixnum] col index of the column (starting at 0)
      # @return [Well]
      def get_well(row, col)
        raise IndexOutOfRangeError unless (0...row_number).include?(row)
        raise IndexOutOfRangeError unless (0...column_number).include?(col)
        @content[row*column_number + col]
      end
      private :get_well

      # Convert a well name to a index (number fro 0 to size -1)
      def well_name_to_index(name)
        raise NotImplementedError
      end

      # Convert an index to String
      # @param [Fixnum] index (stating at 0)
      # @return [String] ex "A1"
      # @todo memoize if needed
      def index_to_well_name(index)

        row = index / column_number
        column = index % column_number

        indexes_to_well_name(row, column)

      end

      def indexes_to_well_name(row, column)
        "#{(row+?A.ord).chr}#{column+1}"
      end

      # This should be set by the user.
      # We mock it to give pools by column
      # @return [Hash<String, Array<String>] pools pool name => list of wells name
      def pools
        # 

        1.upto(column_number).mash do |c|
          [c, 1.upto(row_number).map { |r| indexes_to_well_name(r-1,c-1) } ]
        end


      end
    end
  end
end
