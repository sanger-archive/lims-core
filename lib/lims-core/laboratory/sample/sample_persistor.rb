# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


require 'lims-core/persistence/persistor'
require 'lims-core/laboratory/sample'

module Lims::Core
  module Laboratory
    # @abstract
    # Base for all Sample persistor.
    # Real implementation classes (e.g. Sequel::Aliquot) should
    # include the suitable persistor.
    class Sample::SamplePersistor < Persistor
      Model = Laboratory::Sample

      # Doesn't update. At the moment, samples are managed as an external table
      # For testing convenience saving a new object is allowed but update is not.
      # We don't need to modify sample, so when called this method should do nothing.
      # Ideally the external table should be a read-only view.
      # @param [Resource] object the object 
      # @param [Fixum] id id in the database
      # @return [Fixnum, nil] the Id if save successful.
      def update(object, id, *params)
        id
      end

      # @see {update}
      def delete(object, *params)
      end
    end
  end
end
