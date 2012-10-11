# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims/core/persistence/persistor'
require 'lims/core/organization/study'

module Lims::Core
  module Persistence
    # Base for all Study persistors.
    class Study < Persistor
      Model = Organization::Study
    end
  end
end
