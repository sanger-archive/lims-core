require 'lims-core/persistence/persistor'
require 'modularity'

module Lims::Core
  module Persistence
    module PersistableTrait
      as_trait do |args={}|
        # Define basic persistor
         model_name = self.name.split('::').last
         persistor_name = "#{model_name}Persistor"
         class_eval <<-EOC
         # define Persistor class
          class #{persistor_name} < Persistor
            does 'lims/core/persistence/persistor', #{name}, #{args.inspect}
          end
         EOC
      end
    end
    module PersistorTrait
      as_trait do |model, args|
        self::Model=model
        args[:parents].andtap do |_parents|
          # preprocess parents to get a list
          parents = []
          session_names = {}


          _parents.each do |parent|
            if parent.is_a? Hash
              name = parent[:name].to_s
              session_names[name] =  parent[:session_name] || name
            else
              name = parent.to_s
              session_names[name] =  name
            end
            parents << name
          end

          class_eval <<-EOC
            def filter_attributes_on_load(attributes)
              attributes.mash do |k, v|
                case k
                  #{ parents.map { |p| "when :#{p}_id then [:#{p}, @session.#{session_names[p]}[v]]"}.join(';') }
                else [k,v]
                end
              end
            end

            def attribute_for(key)
              {
                #{ parents.map {|p| "#{p}: '#{p}_id'"  }.join(',')}
              }[key]
            end

            def parents_for_attributes(attributes)
              [
              #{ parents.map { |p| "@session.#{session_names[p]}.state_for_id(attributes[:#{p}])" }.join(',') }
             ]
            end
          EOC
        end
      end
    end
  end
end
