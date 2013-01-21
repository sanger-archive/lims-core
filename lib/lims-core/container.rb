require 'common'

module Lims
  module Core
    # A container is an a laboratory pieces
    # containing other laboratory pieces.
    # Example, a plate or a tube rack.
    module Container
      def self.included(klass)
        klass.extend ClassMethods

        # each_with_index needs to be evaluated using
        # class_eval on Container module inclusion to 
        # redefine the method each_with_index. Otherwise,
        # the normal each_with_index is called as when a 
        # module is included, its methods are placed right 
        # above the class' methods in inheritance chain.
        klass.class_eval do
          # each is already defined to look like an Array.
          # This one provide a "String" index (like "A1") aka
          # element name. It can be used to access the Container.
          def each_with_index
            @content.each_with_index do |well, index|
              yield well, index_to_element_name(index)
            end
          end
        end
      end

      IndexOutOfRangeError = Class.new(RuntimeError)

      module AccessibleViaSuper
        def [](index)
          case index
          when Array
            get_element(*index)
          when /\A([a-zA-Z])(\d+)\z/
            row = $1.ord - ?A.ord
            col = $2.to_i - 1
            get_element(row, col)
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

      # Hash behavior

      # Provides the list of the element names, equivalent to
      # the Hash#keys methods.
      # @return [Array<String>]
      def keys
        0.upto(size-1).map { |i| index_to_element_name(i) }
      end

      # List of the elements, equivalent to Hash#values
      def values
        @content
      end

      def indexes_to_element_name(row, column)
        self.class.indexes_to_element_name(row, column)
      end

      # Convert an index to String
      # @param [Fixnum] index (stating at 0)
      # @return [String] ex "A1"
      # @todo memoize if needed
      def index_to_element_name(index)
        row = index / number_of_columns
        column = index % number_of_columns

        indexes_to_element_name(row, column)
      end

      # Convert a element name to a index (number fro 0 to size -1)
      def element_name_to_index(name)
        raise NotImplementedError
      end

      # return a element from a 2D index
      # Also check the boundary
      # @param [Fixnum] row index of the row (starting at 0)
      # @param [Fixnum] col index of the column (starting at 0)
      # @return [Object]
      def get_element(row, col)
        raise IndexOutOfRangeError unless (0...number_of_rows).include?(row)
        raise IndexOutOfRangeError unless (0...number_of_columns).include?(col)
        @content[row*number_of_columns + col]
      end
      private :get_element


      module ClassMethods
        def indexes_to_element_name(row, column)
          "#{(row+?A.ord).chr}#{column+1}"
        end 
      end
    end
  end
end
