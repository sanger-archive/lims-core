require 'common'

module Lims
  module Core
		module Laboratory
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
						include Virtus
						include Aequitas

						%w(row column).each do |w|
							attribute :"number_of_#{w}s", Fixnum, :required => true, :gte => 0, :writer => :private, :initializable => true
						end

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
							get_element($1, $2)
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

				# Converts an element name to an index of the underlying container
				# The result could be from 0 to size - 1
				def element_name_to_index(row_str, col_str)
					row = row_str.ord - ?A.ord if row_str.is_a?(String)
					col = col_str.to_i - 1 if col_str.is_a?(String)
					raise IndexOutOfRangeError unless (0...number_of_rows).include?(row)
					raise IndexOutOfRangeError unless (0...number_of_columns).include?(col)
					row*number_of_columns + col
				end

				# return a element from a 2D index
				# Also check the boundary
				# @param [Fixnum] row index of the row (starting at 0)
				# @param [Fixnum] col index of the column (starting at 0)
				# @return [Object]
				def get_element(row, col)
					@content[element_name_to_index(row, col)]
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
end
