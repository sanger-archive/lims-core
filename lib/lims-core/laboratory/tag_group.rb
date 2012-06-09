# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en  
require 'common'

require 'lims/core/resource'
require 'lims/core/laboratory/oligo'

module Lims::Core
  module Laboratory
    class TagGroup
      include Resource
      include Forwardable
      attribute :name, String, :writer => :protected, :initializable => true
      is_array_of Oligo

      #module AccessibleViaSuper
        # @param [String, Hash] name the name or a hash of attributes.
        # @param [Oligo, Array<Oligo>] oligos to add to the tag group.
      def initialize(name, *oligos, &block)
        args = {}
        case name
        when String then args[:name] = name
        when Hash then args = name
        end
        super(args, &block)

        @content = oligos.flatten

      end
      #end
      #include AccessibleViaSuper

      # Add additional method delegations
      def_delegators :@content, :<<, :[]=
    end
  end
end
