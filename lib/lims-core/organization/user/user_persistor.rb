# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'lims-core/persistence/persistor'
require 'lims-core/organization/user'

module Lims::Core
  module Organization
    # Base for all User persistors.
    class User::UserPersistor < Persistor
      Model = Organization::User
    end
  end
end
