# vi: ts=2 sts=2 et sw=2 spell spelllang=en  
require 'common'

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

      def is_a_hash_of(key_class, value_class,  &initializer)
        define_method :initialize_hash do |*args|
          @content = initializer ? initialize[self, key_class, value_class] : {}
        end
        class_eval do
          include Enumerable
          include IsHashOf
          def_delegators :@content, :each, :size , :keys, :values, :map, :mashr , :include?, :to_a 
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

      # iterate only between non empty lanes.
      # @yield [content]
      # @return itself
      def each_content
        @content.each do |content|
          yield content if content
        end
      end
    end 
    module IsHashOf

      def initialize(*args, &block)
        super(*args, &block)
        initialize_hash()
      end

      # Add content to compare
      # @param other to compare with
      # @return [Boolean]
      def ==(other)
        super(other) && content == (other.respond(:content) || other)
      end

      # The underlying hash. Use to everything which is not directly delegated 
      # @return [Hash]
      def content
        @content 
      end

      # Delegate [] to the underlying Hash.
      # This is needed because Virtus redefine [] as well 
      # @param [Fixnum, ... ] i index
      # @return [Object]
      def [](i)
        case i
        when String, Symbol
          if respond_to?(i)
            super(i) # attributes
          else
            @content[i]
          end
        else super(i)
        end
      end

      def [](key, value)
        debugger
        case key
        when String, Symbol
          if respond_to?(key)
            super(key, value)
          else
            @content[key]=value
          end
        else
          super(key, value)
        end
      end
    end 
  end
end
