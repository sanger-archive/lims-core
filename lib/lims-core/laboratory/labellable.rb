require 'common'

module Lims::Core
  module Laboratory
    # A labellable is something which can have one or more labels.
    # By labels we mean any readable information found on a physical oblect.
    # This can be serial number, stick label with barcode etc.
    # {Label} can eventually be identified by a position : an a arbitray string (not a Symbol).
    # The semantic of the position is left to pipeline.
    # A label as a name , unique identifier and a type, which should indicate
    # if it's a resource (plate, tube) an equipment a user etc ...
    # Labellable acts mainly has a hash of location => labels
    class Labellable
      include Resource
      attribute :name, String, :required => true, :writer => :private, :initializable => true
      attribute :type, String, :required => true, :writer => :private, :initializable => true
      attribute :content, Hash, :default => {}, :writer => :private, :initializable => true

      def initialize(*args, &block)
        super(*args, &block)
      end

      include Enumerable
      def_delegators :content, :each, :size, :each_with_index, :map, :zip, :clear, :include? \
        ,:to_a, :keys, :values, :delete, :fetch



      # We need to redefine [] and []=
      # as Virtus it to computes attributes
      # Therefore, we use the Virtus method for Symbols.
      # Everything else, is redirected to content.
      # i.e. 
      #     labellable[:name]  # == labellable.name
      #     labellable["name"] # label in position "name".
      def [](key)
        case key
        when Symbol
          super(key)
        else
          content[key]
        end
      end

      def []=(key, value)
        case key
        when Symbol
          super(key, value)
        else
          content[key] = value
        end
      end

      def empty?
        false
      end

      # Return all positions
      # @return [Array<String>]
      def positions
        content.keys
      end


      # @return [Array<Label>]
      def labels
        content.values
      end

      def self.type_to_class
        @@type_to_class ||= begin

      end
    end

    # Mixin needed by Object wanted to be 
    # attached to a Labellable
    # Its value correspond to what will be scanned and what will be
    # looked up in the database.
    # The actual formatting of it to the final user would be done
    # in the API server
    # Type needs to be defind by the class in the initializing
    module Label
      @@subclasses = Set.new()
      def self.included(klass)
        klass.instance_eval do
          include Resource
          include After
          attribute :value, String, :required => true
          attribute :type, String, :writter => true, :required => true
        end

        @@subclasses << klass
      end

      def self.new(attributes)
        type = attributes.delete(:type)
        klass = type_to_class(type)
        raise RuntimeError, "No class associated to label type '#{type}'" unless klass
        klass.new(attributes)
      end

      def self.type_to_class(type)
        @@type_to_subclass ||= @@subclasses.mash { |s| [s::Type, s] }
        @@type_to_subclass[type]
      end


      module After
        def initialize(*args, &block)
          @type = self.class::Type
          super(*args, &block)
        end
      end
    end
  end
end
end
require 'lims/core/laboratory/barcode_2d'
require 'lims/core/laboratory/sanger_barcode'
require 'lims/core/laboratory/ean13_barcode'
