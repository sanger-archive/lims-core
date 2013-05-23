#vi: ts=2 sw=2 et
require 'common'
require 'facets/string'

require 'lims-core/persistence/session'

module Lims::Core
  # Generic persistence layer.
  # The main objects are {Persistence::Session Session} which
  # is in charge of saving and restoring object and {Persistence::Store} via Persistors.
  # Persistors are mixins specific to each persistence types.
  # For example, see the {Sequel::Persistor}.
  module Persistence
  end
end
