# vi: ts=2 sts=2 et sw=2 spell spelllang=en  
require 'common'

module Lims::Core
  module Resource
    def self.included(klass)
      klass.class_eval do
        include Virtus
        extend Forwardable

        def self.is_array_of(child_klass, options = {},  &initializer)
            define_method :initialize do |*args, &block|
              super(*args, &block)
              @content = initializer ? initializer[self, child_klass] : []
            end

          class_eval do

            include Enumerable

            # Add content to compare
            # @param other to compare with
            # @return [Boolean]
            def ==(other)
              super(other) && content == (other.respond(:content) || other)
            end

            # The underlying array. Use to everything which is not directly delegated 
            # @return [Array]
            def content
              @content 
            end

            def_delegators :@content, :each, :size , :each_with_index, :map, :zip, :clear, :empty?, :to_s \
              , :include?, :to_a

            # Delegate [] to the underlying array.
            # This is needed because Virtus redefine [] as well 
            # @param [Fixnum, ... ] i index
            # @return [Object]
            def [](i)
              case i
              when Fixnum then self.content[i]
              else super(i)
              end
            end

            # iterate only between non empty lanes.
            # @yield [content]
            # @return itself
            def each_content
              @content.each do |content|
                yield content if content
              end
            end
          end 
        end
      end
    end

    # Compare 2 resources.
    # They are == if they have the same values (attributes),
    # regardless they are the same ruby object or not.
    # @param other
    # @return [Boolean]
    def ==(other)
      self.attributes == (other.respond(:attributes) || {} )
    end
  end
end
