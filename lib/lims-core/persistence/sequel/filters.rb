require 'lims/core/persistence/sequel/persistor'
require 'active_support/inflector'

module Lims::Core
  module Persistence
    module Sequel
      # Implementes filter methods needed by persitors.
      module Filters
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

        protected
        # @param Hash criteria
        # @return Persistor
        def __multi_criteria_filter(criteria)
          # Extract critera recursively and apply subhashes to
          # joined table
          # Hash value are criteria for the corresponding joined tabled
          # We need to extract them and do the obvious join
          joined = criteria.reduce(self) do |persistor, (key, value)|
            case value
            when Hash
              joined_persistor = persistor.send(key).__multi_criteria_filter(value)
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
end

