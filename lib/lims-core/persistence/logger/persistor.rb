# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en


module Lims::Core
  module Persistence
    module Logger
      # Mixin giving extended the persistor classes with
      # the Logger (save) behavior.
      module Persistor
        private

        # Load an object to the underlying logger
        # @param [Resource] object the object 
        # @return  the Id if save successful
        def save_raw(object, *params)
          case object 
            when Resource then @session.log("#{object.class.name}: #{filter_attributes_on_save(object.attributes)}")
            else
            @session.log("#{object.inspect}")
            end
          object
        end

        # Overriden the default save new to add indentation
        # around children
        def save_new(object, *params)
          save_raw(object, *params).tap do |id|
            @session.with_indent("- ") { save_children(id, object) }
          end
        end

        # Upate a raw object, i.e. the object attributes
        # excluding any associations.
        # @param [Resource] object the object 
        # @param [Fixnum] id the Id of the object
        # @return [Fixnum, nil] the id 
        def update_raw(object, id, *params)
          id.tap do
            save_raw(object, *params)
          end
        end

        def save_as_aggregation(source_id, target, *params)
          @session.with_indent("#{params} - ") do
            super(source_id, target)
          end
        end

        def save_raw_association(source_id, target_id, *params)
        end
      end
    end
  end
end
