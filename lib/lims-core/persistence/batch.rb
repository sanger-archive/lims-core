# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'lims/core/persistence/persistor'
require 'lims/core/organization/batch'

module Lims::Core
  module Persistence
    class Batch < Persistor
      Model = Organization::Batch
    end
  end
end
