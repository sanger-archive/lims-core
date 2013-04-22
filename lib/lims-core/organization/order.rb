# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'common'
require 'lims-core/resource'
require 'lims-core/organization/user'
require 'lims-core/organization/study'
require 'lims-core/organization/order/item'

require 'state_machine'

StateMachine::Machine.ignore_method_conflicts = true
module Lims::Core
  module Organization
    # An order represents the idea of 'work to be done'.
    # However, an order focuses more on the final outcomes than the steps to achieve it.
    # The way to fulfil this order is specified via a `pipeline` and its `parameters`, which **knows** how to do it.
    # This allows the flexibility for a pipeline to adapt its process without having to modify the corresponding order.
    # The current *progress* of the order - what has been done so far - is then no stored as "what steps have been done",
    # but more as "which *items* exits". To make this work ,we also needs to know how each items participates in the order, meaning its `role`.
    # For example, in the case that user U needs sample S to be sequenced, what we need to know is we *have* sample S as a **source** and want
    # we want a *sequence* as *result*.
    # To do so, we need to create a library from the sample. Once this library is created, it becomes part of the order as **library**.
    # The pipeline will then know that the **library** has been created and that the next step can start.
    # Note, there is no relation at a core level between this sample and this library. The pipeline *knows* that this **sample** is linked to that **library**.
    # Ultimately, someone wanted to sequence an existing library, can create an order with the same parameters, with the **library** given instead of the **sample**.
    class Order

      include Resource
      attribute :creator, User, :required => true, :writer => :private, :initializable=>true
      attribute :pipeline, String, :required => true
      attribute :items, HashString, :default => {}, :reader => :private, :writer => :private, :initializable => true

      attribute :status, State
      attribute :parameters, Hash, :default => {}
      attribute :state, Hash, :default => {}
      attribute :study, Study, :required => true, :writer => :private, :initializable=>true
      attribute :cost_code, String, :required => true, :writer  => :private, :initializable=>true

      # An order has a status, which is its progress from an end-user 
      # point of view. This status is more meant to be used by 
      # Order related applications (like ones dealing with creation
      # or tracking) that the pipeline. Ideally the pipeline should
      # be involved in the :in_progress state.
      # The status will affect the behavior of validation and 
      # certain methods.
      state_machine :status, :initial  => :draft do
        # This is the initial state. The order is not finalized yet.
        # It can be modified, and should not be *visible* by the pipeline.
        state :draft do
        end

        # The order has been *validated* by the user and it's ready 
        # to pe processed.
        state :pending do
        end

        state all - [:draft] do
          def creator=(creator)
            raise NoMethodError, "creator can't be assigned in #{status} mode"
          end

          def study=(study)
            raise NoMethodError, "study can't be assigned in #{status} mode"
          end

          def cost_code=(cost_code)
            raise NoMethodError, "cost code can't be assigned in #{status} mode"
          end
        end
        # the order has been physically started, .i.e it's belong
        # to a pipeline and some work is currently being done.
        state :in_progress do
        end

        # the order has been fulfilled with success. It should not be
        # modifiable without rewriting history.
        state :completed do
        end

        # For whatever reason, the order can not be completed.
        # Shouldn't be modifiable.
        state :failed do
        end

        # The order has been cancelled by a user decision.
        # Shouldn't be modifiable.
        state :cancelled do
        end

        event :build do
          transition :draft => :pending
        end

        event :start do
          transition :pending => :in_progress
        end

        event :complete do
          transition :in_progress => :completed
        end

        event :cancel do
          transition [:draft, :pending, :in_progress] => :cancel
        end

        event :fail do
          transition [:draft, :pending, :in_progress] => :failed
        end
      end

      # ========= Items ========
      # Redirect key to either items or attributes (default
      # Virtus behavior
      def [](key)
        key_is_for_items?(key) ? items[key.to_s] : super(key)
      end

      def []=(key, value)
        if key_is_for_items?(key) 
          raise RuntimeError, "items should be an array" unless value.is_a?(Array)
          items[key.to_s]=value 
        else
          super(key, value)
        end
      end

      # Add an item to the specified role
      # Ideally, uuid should be unique within a role
      # @param String role
      # @param Item item
      def add_item(role, item)
        role = role.to_s
        item_list = items.fetch(role) { |k| items[role] = [] }
        item_list << item
        return item
      end

      def_delegators :items, :each, :size , :keys, :values, :map, :mashr , :include?, :to_a , :fetch

      # Check if the argument is a key for items
      # or attributes
      # @param [Object] key
      # @return [Boolean]
      def key_is_for_items?(key)
        case key
        when String, Symbol then !respond_to?(key)
        end || false
      end
      private :key_is_for_items?

      # A source is an item required to complete the order.
      # There is nothing to do for it, so it's already in a done state.
      # As the source is meant to be used by the pipeline to fulfil the order
      # it needs an underlying object.
      # @param [String] role of the source
      # @param [Array, String] uuids of the underlying object
      # @return [Item]
      def add_source(role, uuids)
        uuids = [uuids] unless uuids.is_a?(Array)
        uuids.each do |uuid|
          Item.new(:uuid => uuid).tap do |item|
            item.complete
            self.add_item(role, item)
          end
        end
      end

      # A target is an item produced by the order.
      # It starts as pending and needs to be completed or failed.
      # @param [String] role of the target
      # @param [String] uuid of the underlying object
      # @return [Item]
      def add_target(role, uuids = nil)
        uuids = [uuids] unless uuids.is_a?(Array)
        uuids.each do |uuid|
          self.add_item(role, Item.new(:uuid => uuid))
        end
      end
    end
  end
end

