# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'common'
require 'lims/core/resource'

module Lims::Core
  module Organization
    # A batch groups multiple items together.
    class Batch
      include Resource
    end
  end
end
