# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'common'
require 'lims-core/resource'

module Lims::Core
  module Organization
    # A batch groups multiple items together.
    class Batch
      include Resource
      # Store the process that the batch is going through.
      # Ex: 8 tubes might go through the process "manual extraction".
      attribute :process, String, :required => false
    end
  end
end
