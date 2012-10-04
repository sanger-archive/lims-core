# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'common'
require 'lims/core/resource'
require 'lims-core/organization/user'
require 'lims-core/organization/study'

require 'state_machine'

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
      attribute :parameters, Hash, :default => {}
      attribute :state, Hash, :default => {}
      attribute :study, Study, :required => true, :writer => :private, :initializable=>true
      attribute :cost_code, String, :required => true, :writer  => :private, :initializable=>true
      #substate ? pipeline need a different state ?
      #

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
          def creator=(creator)
            @creator=creator
          end

          def study=(study)
            @study=study
          end

          def cost_code=(cost_code)
            @cost_code=cost_code
          end

        end

        # The order has been *validated* by the user and it's ready 
        # to pe processed.
        state :pending do
        end

        # the order has been physically started, .i.e it's belong
        # to a pipeline and some work is currently being done.
        state :in_progress

        # the order has been fulfilled with success. It should not be
        # modifiable without rewriting history.
        state :completed

        # For whatever reason, the order can not be completed.
        # Shouldn't be modifiable.
        state :failed

        # The order has been cancelled by a user decision.
        # Shouldn't be modifiable.
        state :cancelled

        event :start do
        end
      end
    end
  end
end
 
