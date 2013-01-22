# vi: ts=2 sts=2 et sw=2 spell spelllang=en  
require 'common'
require 'lims-core/container'

module Lims::Core
  module Resource
    def self.included(klass)
      klass.class_eval do
        include Virtus
        include Aequitas
        include AccessibleViaSuper
        extend Forwardable
        extend ClassMethod
      end
    end

    module AccessibleViaSuper
      def initialize(*args, &block)
        # readonly attributes are normaly not allowed in constructor
        # by Virtus. We need to call set_attributes explicitely
        options = args.extract_options!
        # we would use `options & [:row ... ]` if we could
        # but Sequel redefine Hash#& ...
        initializables = self.class.attributes.select {|a| a.options[:initializable] == true  }
        initial_options  = options.subset(initializables.map(&:name))
        set_attributes(initial_options)
        super(*args, options - initial_options, &block).tap {
        }
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


    module ClassMethod
      def is_array_of(child_klass, options = {},  &initializer)
        define_method :initialize_array do |*args|
          @content = initializer ? initializer[self, child_klass] : []
        end

        class_eval do
          include Enumerable
          include IsArrayOf
          def_delegators :@content, :each, :size , :each_with_index, :map, :zip, :clear, :empty?, :to_s \
            , :include?, :to_a, :first, :last

        end
      end

      def is_matrix_of(child_klass, options = {},  &initializer)
        element_name = child_klass.name.split('::').last.downcase
        class_eval do
          is_array_of(child_klass, options, &initializer)
          include Container

          define_method "get_#{element_name}" do |*args|
            get_element(*args)
          end

        end
      end
    end


    module IsArrayOf

      def initialize(*args, &block)
        super(*args, &block)
        initialize_array()
      end

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

      def []=(i, value)
        case i
        when Fixnum then self.content[i]=value
        else super(i, value)
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

    class HashString < Virtus::Attribute::Object
      primitive Hash
      def coerce(hash)
        hash.rekey  {|key| key.to_s }
      end
    end

    # @todo override state_machine to automatically add
    # attribute
    class State < Virtus::Attribute::Object
      primitive String
    end
  end
end
