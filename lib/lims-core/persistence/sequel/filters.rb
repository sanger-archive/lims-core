require 'lims-core/persistence/sequel'
require 'active_support/inflector'

module Lims::Core
  module Persistence
    # Implementes filter methods needed by persitors.
    module Sequel::Filters

      LIKE_OPERATOR = 'LIKE'
      COMPARISON_OPERATORS = ["<", "<=", "=", ">=", ">", LIKE_OPERATOR]

      # Implement a multicriteria filter for a Sequel::Persistor.
      # Value can be either a String, an Array  or a Hash.
      # Strings and Arrays are normal filters, whereas Hashes
      # correspond to a joined search. The criteria will apply to the 
      # joined object corresponding to the key.
      # @param [Hash<String, Object > criteria
      # @return [Persistor]
      def multi_criteria_filter(criteria)
        # We need to create the adequat dataset.
        dataset = __multi_criteria_filter(criteria).dataset
        # As the dataset can include join, we need to select only the columns
        # corresponding to the persistor
        self.class.new(self, dataset.qualify(table_name).distinct())
      end

      # Implement a comparison filter for a Sequel::Persistor.
      # Key being the name of the resource's field and the value is a Hash.
      # The key of the hash is a comparison operator
      # and the value is the given value the filter do the comparison against.
      # @param [Hash<String, Object>] criteria
      # @return [Persistor]
      def comparison_filter(criteria)
        clause = ""
        criteria.each do |field, comparison_expression|
          comparison_expression.each do |operator, value|
            if operator.upcase == LIKE_OPERATOR
              operator = operator.upcase
              value = "%#{value}%" if operator == LIKE_OPERATOR
            end

            raise ArgumentError, "Not supported comparison operator has been given: '#{operator}'" unless COMPARISON_OPERATORS.include?(operator) 

            clause = clause + ') & (' unless clause == ""
            clause = clause + " #{field} " + operator + "'#{value}'"
          end
        end

        self.class.new(self, dataset.where(clause).qualify)
      end

      # Joins the comparison filter to the existing persistor.
      # @param [Dataset] dataset
      # @param [Hash<String, Object>] criteria for the comparison
      # @return [Persistor]
      def add_comparison_filter(dataset, comparison_criteria)
        comparison_persistor = comparison_filter(comparison_criteria)
        self.class.new(self, dataset.join(comparison_persistor.dataset, :id => :key).qualify)
      end

      protected
      # @param Hash criteria
      # @return Persistor
      def __multi_criteria_filter(criteria)
        # Extract critera recursively and apply subhashes to
        # joined table
        # Hash value are criteria for the corresponding joined tabled
        # We need to extract them and do the obvious join
        # Values are passed to filter_attributes_on save to get
        # the right format if needed.
        joined = criteria.reduce(self) do |persistor, (key, value)|
          case value
          when Hash
            criteria_persistor = persistor.send(key)
            filtered_value = criteria_persistor.filter_attributes_on_save(value.rekey {|k| k.to_sym})
            joined_persistor = criteria_persistor.__multi_criteria_filter(filtered_value)
            __join(joined_persistor)
          else persistor
          end
        end

        # We need to passes to filter are applied on the joined persistor.
        # This is needed because the __join function expected bare persistor 
        # and will loose any filter applied on the original persistor
        criteria.reduce(joined) do |persistor, (key, value)|
          case value
          when Hash
            persistor
          else
            self.class.new(persistor, persistor.dataset.filter(::Sequel.qualify(table_name, key) => value))
          end
        end
      end

      # Assume that the original persistor his *blank* ie 
      # it doesn't contain any SQL modifier
      # @param [Persistor] persistor
      # @return [Persistor]
      def __join(persistor)
        self.class.new(self, persistor.dataset.join(table_name, primary_key => :"#{table_name.to_s.singularize}_#{persistor.primary_key}"))
      end

    end
  end
end

