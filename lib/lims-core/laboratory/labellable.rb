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
      attribute :name, String, :required => true, :write => :private, :initializable => true
      attribute :type, String, :required => true, :write => :private, :initializable => true
      attribute :content, Hash, :default => {}, :write => :private, :initializable => true

      def initialize(*args, &block)
        super(*args, &block)
#        @content = {}
      end

      include Enumerable
      def_delegators :@content, :each, :size, :each_with_index, :map, :zip, :clear, :empty?, :include? \
        ,:to_a, :keys, :values, :delete, :fetch, :[], :[]=


        # Return all positions
        # @return [Array<String>]
      def positions
        content.keys
      end


    # @return [Array<Label>]
      def labels
        content.values
      end

      # TODO ke4 temporary fix - remove it later, when Maxime fixed the related defect
      def attributes
        {:name => @name,
         :type => @type,
         :content => @content }
      end

      # Mixin needed by Object wanted to be 
      # attached to a Labellable
      # Its value correspond to what will be scanned and what will be
      # looked up in the database.
      # The actual formatting of it to the final user would be done
      # in the API server
      # Type needs to be defind by the class in the initializing
      module Label
        def self.included(klass)
          klass.instance_eval do
            include Resource
            include After
            attribute :value, String, :required => true
            attribute :type, String, :writter => true, :required => true
          end
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
