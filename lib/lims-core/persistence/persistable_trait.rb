require 'lims-core/persistence/persistor'
require 'modularity'

module Lims::Core
  module Persistence
    module PersistableTrait
      as_trait do 
        # Define basic persistor
         debugger 
         model_name = self.name.split('::').last
         persistor_name = "#{model_name}Persistor"
         class_eval <<-EOC
         # define Persistor class
          class #{persistor_name} < Persistor
            Model=#{name}
          end
         EOC
      end
    end
  end
end
