# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'common'
require 'lims/core/resource'

module Lims::Core
  module Organization
    # An order is what a project manager is asking for, typically
    # some samples to be sequenced in a particular way.
    class Order
      include Resource
    end
  end
end
