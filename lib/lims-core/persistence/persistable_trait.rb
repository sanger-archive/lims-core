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
        model_name = model.name.split('::').last
        parents = []
        deletable_parents = []
        session_names = {}
        skip_parents_for_attributes = {}

        args[:parents].andtap do |_parents|
          # preprocess parents to get a list

          _parents.each do |parent|
            if parent.is_a? Hash
              name = parent[:name].to_s
              session_names[name] =  parent[:session_name] || name
              skip_parents_for_attributes[name] = parent[:skip_parents_for_attributes] 
              deletable_parents << name if parent[:deletable]
            else
              name = parent.to_s
              session_names[name] =  name
            end
            parents << name
          end
        end

        children = []
        deletable_children  = []
        args[:children].andtap do |_children|
          _children.each do |child|
            if child.is_a? Hash
              name = child[:name].to_s
              deletable_children << name if child[:deletable]
            else
              name = child.to_s
              session_names[name] =  name
            end
            children << name
          end
        end

        if parents.size >= 1
          class_eval <<-EOC
          def filter_attributes_on_load(attributes)
            attributes.mash do |k, v|
              case k
                #{ parents.map do |p|
                    "when :#{p}_id then [:#{p}, (@session_#{p} ||= @session.#{session_names[p]})[v]]"
                  end.join(';') 
                }
              else [k,v]
              end
            end
          end

          def attribute_for(key)
            {
              #{ parents.map {|p| "#{p}: '#{p}_id'"  }.join(',')}
            }[key]
          end

          def parents(resource)
            [
              #{ parents.map do |p|
                  "resource.#{p}"
                  end.join(',') }
            ].compact
          end

          def parents_for_attributes(attributes)
            [
              #{ parents.reject{|p| skip_parents_for_attributes[p] }.map do |p|
                  "(@session_#{p} ||= @session.#{session_names[p]}).state_for_id(attributes[:#{p}_id])" 
                  end.join(',') }
            ]
          end
          EOC
        end
        unless children.empty? 
          class_eval <<-EOC
          def children(resource)
            [].tap do |list|
              #{
                children.map do |child|
                  "children_#{child}(resource, list)"
                end.join(';')
              }
            end
          end

          def load_children(states)
              #{
                children.map do |child|
                  "#{child}.find_by(:#{model_name.snakecase}_id => states.map(&:id))"
                end.join(';')
              }
              1
          end
          EOC
        end

        unless deletable_children.empty? 
          class_eval <<-EOC
          def deletable_children(resource)
            [].tap do |list|
              #{
                deletable_children.map do |child|
                  "children_#{child}(resource, list)"
                end.join(';')
              }
            end
          end
          EOC
        end
        unless deletable_parents.empty? 
          class_eval <<-EOC
          def deletable_parents(resource)
            [].tap do |list|
              #{
                deletable_parents.map do |parent|
                  "resource.#{parent}.andtap { |p| list << p }"
                end.join(';')
              }
            end
          end
          EOC
        end
        self
      end
    end
  end
end
