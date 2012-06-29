#vi: ts=2 sw=2 et
require 'common'
require 'facets/string'


module Lims::Core
  # Generic persistence layer.
  # The main objects are {Persistence::Session Session} which
  # is in charge of saving and restoring object and {Persistence::Store} via Persistors.
  # Persistors are mixins specific to each persistence types.
  # For example, see the {Sequel::Persistor}.
  module Persistence

    # Creates all the missing for a submodule.
    # Needs to be called  once for each submodule
    def self.finalize_submodule(mod)
      require_all("#{mod.name.pathize.sub('lims/core/',"")}/*")
      generate_missing_classes(self, mod, mod::Persistor)
    end

    # Generate all the 'missing' persistors (.i.e. those
    # existing in the main Persistence module but which 
    # haven't been subclassed.
    # @param mod the module to add class into.
    def self.generate_missing_classes(base, mod, persistor)
      (base.constants(false)-mod.constants(false)).map { |c| base.const_get(c) }.each do |klass|
        case
        when klass == Persistor then next
        when klass.ancestors.include?(Persistor) 
          generate_persistor(klass, mod, persistor)
        end
      end
    end

    # Generate a persistor inheriting from  klass
    #  and extended with the 'local' persistor.
    def self.generate_persistor(klass, mod, persistor)
      class_name = klass.name.split("::").last
      generated_class = mod.class_eval %Q{
        class #{class_name} < ::#{klass.name}
          include ::#{persistor.name}
        end
      }

      # generate nested classes, ex Plate::Well
        generate_missing_classes(klass, generated_class, persistor)
    end
  end
end

require 'lims/core/persistence/store'
require 'lims/core/persistence/aliquot'
require 'lims/core/persistence/flowcell'
require 'lims/core/persistence/oligo'
require 'lims/core/persistence/persistor'
require 'lims/core/persistence/plate'
require 'lims/core/persistence/session'
require 'lims/core/persistence/store'
require 'lims/core/persistence/tag_group'
require 'lims/core/persistence/tube'
require 'lims/core/persistence/uuid_resource'
