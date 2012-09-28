# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'common'
require 'lims/core/resource'

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
    end
  end
end
 
