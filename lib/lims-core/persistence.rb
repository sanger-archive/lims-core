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

    # Creates all the missing for a submodule.
    # Needs to be called  once for each submodule
    # if NO_AUTOLOAD is specified and no path are provided
    # We skip it. Thif function needs to be called with an explicit path
    # (which could be [] everything has already been preloaded)
    # @param [Module] mod module to finalize
    # @paths [Array<String>]  paths where the persistor to finalize are defined
    def self.finalize_submodule(mod, paths=nil)
		return # @todo remove after refactoring
      return if defined?(NO_AUTOLOAD) && !paths
      paths ||= ["#{mod.name.pathize.sub('lims-core/',"")}/*"]
      paths.map { |path| require_all(path) }
      generate_missing_classes(self, mod, mod::Persistor)

    end

    # Generate all the 'missing' persistors (.i.e. those
    # existing in the main Persistence module but which 
    # haven't been subclassed.
    # @param mod the module to add class into.
    def self.generate_missing_classes(base, mod, persistor)
      (base.constants(false)-mod.constants(false)).map { |c| base.const_get(c) }.each do |klass|
        case
        when klass.is_a?(Class) == false then next
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
