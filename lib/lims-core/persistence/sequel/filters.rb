require 'lims-core/persistence/sequel'
require 'active_support/inflector'

module Lims::Core
  module Persistence
    # Implementes filter methods needed by persitors.
    module Sequel::Filters
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

      # Implements a label filter for a Sequel::Persistor.
      # Nil value would be ignored
      # @param [String, Nil] position of the label 
      # @param [String, Nil] value of the label
      # @param [String, Nil] type fo the label
      # @return [Persistor]
      def label_filter(criteria)
        labellable_dataset = @session.labellable.__multi_criteria_filter(criteria).dataset

        # join labellabe request to uuid_resource
        # If the persistor class is a Sequel::Labellable, it means
        # the searched resource is a labellable. Then the joint with
        # uuid_resources is made between uuid_resources#key and
        # labellables#id.
        uuid_resources_joint = self.class == Labels::Labellable::LabellableSequelPersistor ? {:key => :"id"} : {:uuid => :"name"}
        persistor = self.class.new(self, labellable_dataset.join("uuid_resources", uuid_resources_joint).select(:key).qualify(:uuid_resources))

        # join everything to current resource table
        # Qualify method is needed to get only the fields related to the searched
        # resource. Otherwise, multiple id columns are returned which lead to a
        # ambiguous situation when we try to get the id of the resource. 
        # This leads to an incorrect uuid for the found resources.
        self.class.new(self, dataset.join(persistor.dataset, :key => primary_key).qualify)
      end

      # Implement an order filter for a Sequel::Persistor.
      # @param [Hash<String, Object>] criteria
      # @example
      #     {:order => {:item => {:status => "pending"}, :status => "draft"}}
      #     Create a request to get the resources in a draft order
      #     with a pending item status.
      #     @return [Persistor]
      def order_filter(criteria)
        criteria = criteria[:order] if criteria.keys.first.to_s == "order"
        order_persistor = @session.order.__multi_criteria_filter(criteria)
        order_dataset = order_persistor.dataset

        # If criteria doesn't include an item key, we need 
        # to make the join with the table items here.
        unless criteria.has_key?("item") or criteria.has_key?(:item)
          order_dataset = order_dataset.join(:items, :order_id => order_persistor.primary_key)
        end
        
        # Join order dataset with the uuid_resources table 
        order_dataset = order_dataset.join(:uuid_resources, :uuid => :items__uuid).select(:key).qualify(:uuid_resources) 

        # Join order dataset with the resource dataset
        # Qualify method is needed to get only the fields related
        # to the resource table. Otherwise, id could be confused.
        # The expected request would be for example something like
        # select plates.* from ...
        # As a same resource could belong to multiple orders, distinct
        # is used to get only one copy of each resource.
        self.class.new(self, dataset.join(order_dataset, :key => primary_key).qualify.distinct)
      end

      # Implement a batch filter for a Sequel::Persistor.
      # @param [Hash<String, Object>] criteria
      # @example
      #   {:batch => {:uuid => '11111111-2222-3333-4444-555555555555'}}
      #   Create a request to get the resources which are referenced by
      #   an order item assigned to a batch with the given uuid.
      #   Is equivalent to the criteria:
      #   {:order => {:item => {:batch => {:uuid => '11111111-2222-3333-4444-555555555555'}}}}
      def batch_filter(criteria)
        order_filter({:order => {:item => criteria } })
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

