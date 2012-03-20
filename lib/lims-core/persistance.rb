#vi: ts=2 sw=2 et


module Lims::Core
  # Generic persistance layer.
  # The main objects are {Persistance::Session Session} which
  # is in charge of saving and restoring object and {Persistance::Store} via Persistors.
  # Persistors are mixins specific to each persistance types.
  # For example, see the {Sequel::Persistor}.
  module Persistance
  end
end
