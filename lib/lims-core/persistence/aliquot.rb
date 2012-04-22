# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims/core/persistence/persistor'
require 'lims/core/laboratory/aliquot'

module Lims::Core
  module Persistence
    # @abstract
    # Base for all Aliquot persistor.
    # Real implementation classes (e.g. Sequel::Aliquot) should
    # include the suitable persistor.
    class Aliquot < Persistor
      Model = Laboratory::Aliquot
      end
  end
end
