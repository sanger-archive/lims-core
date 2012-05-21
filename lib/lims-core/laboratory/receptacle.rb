# vi: ts=2 sts=2 et sw=2 spell spelllang=en  
require 'common'
require 'lims/core/laboratory/aliquot'
require 'lims/core/resource'

require 'forwardable'

module Lims::Core
  module Laboratory
    # A Receptacle has a chemical content which is a set of {Laboratory::Aliquot aliquots}.
    # It can be seen (and used) as a Array of Aliquots (until a certain extend).
    # {include:Laboratory::Aliquot}
    module Receptacle

      def self.included(klass)
        klass.class_eval do
          include Resource

          is_array_of(Aliquot) { |l,t| Array.new }

          # Add something to the receptacle.
          # Could be one or many {Aliquot aliquots}
          # @param [Aliquot, Array<Aliquot>]
          def <<(e)
            debugger if $stop
            tap do
              if e.respond_to?(:to_a)
                  content.concat(e.to_a)
              else
                  content << e
              end
            end
          end

          # returns the total quantity of liquid present in the receptacle.
          # for liquid, this is the sum  of each aliquot.
          # @todo to be correct we need the actual quantity of water AND of chemical substance.
          # @return Float
          def quantity
            content.inject(0) { |q, a| a.quantity && q ?  q+a.quantity : nil }
          end

          # Takes (removes) a specified amount of each aliquots (proportionally)
          # @param amount
          # @return [Array<Laboratory::Aliquot>]
          def take(amount=nil)
            # @todo : implement
            # take_fraction
            take_fraction(amount ? amount/quantity : 1.0)
          end

          # Takes (removes) a specified amount of each aliquots (proportionally)
          # @param [Float] f the fraction (between 0.0 and 1.0) of each aliquots to take.
          # @return [Array<Laboratory::Aliquot>]
          def take_fraction(f)
            content.map {|a| a.take_fraction(f) }
          end
        end
      end
    end
  end
end

