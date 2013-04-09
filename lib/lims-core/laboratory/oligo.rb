require 'common'

require 'lims-core/resource'
require 'forwardable'

module Lims::Core
  module Laboratory
    # A tag is a sequence of DNA meant to be bound to a sample to recognize
    # from other samples in the same multiplex.
    class Oligo
      include Resource
      include Forwardable
      attribute :sequence, String, :writer => :protected, :initializable => true

        # @param [String, Hash] sequence a Sequence or attribute set.
      def initialize(sequence)
        args = {}
        case sequence
        when String then args[:sequence] = sequence
        when Hash then args = sequence
        end

        super(args)
      end

      def ==(other)
        case other
          when String  then  sequence == other
          when Oligo then sequence == other.sequence
          else false
          end
      end


      def_delegators :@sequence, :each, :size, :map
      def to_s
        @sequence.to_s
      end
    end
  end
end
