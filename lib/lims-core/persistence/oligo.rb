# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/oligo'

module Lims::Core
  module Persistence

    # Base for all Plate persistor.
    # Real implementation classes (e.g. Sequel::Plate) should
    # include the suitable persistor.
    class Oligo < Persistor
      Model = Laboratory::Oligo
    end
  end
end
