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
            tap do
              if e.respond_to?(:to_a)
                  content.concat(e.to_a)
              else
                # we need to add aggregate similar aliquot and
                 content.each do |aliquot|
                   next unless aliquot === e
                   # wound a similar aliquot, update the quantity
                   aliquot.increase_quantity(e.quantity)
                   return
                end
                  content << e
              end
            end
          end

          # returns the total quantity of liquid present in the receptacle.
          # for liquid, this is the sum  of each aliquot.
          # @todo to be correct we need the actual quantity of water AND of chemical substance.
          # @return Float
          def quantity(dimension=Aliquot::Volume)
            content.select { |a| a.dimension == dimension }.inject(nil) { |q, a| Aliquot::add_quantity(q, a.quantity) }
          end

          def volume
            quantity(Aliquot::Volume)
          end

          # Takes (removes) a specified amount of each aliquots (proportionally)
          # @param amount
          # @return [Array<Laboratory::Aliquot>]
          def take_amount(amount=nil, dimension=Aliquot::Volume)
            # @todo : implement
            # take_fraction
            take_fraction(amount && quantity(dimension) ? amount/quantity(dimension).to_f : nil)
          end

          # Takes (removes) a specified amount of each aliquots (proportionally)
          # @param [Float] f the fraction (between 0.0 and 1.0) of each aliquots to take.
          # @return [Array<Laboratory::Aliquot>]
          def take_fraction(f)
            f = [0, f, 1].sort[1] if f # clamp
            content.map {|a| a.take_fraction(f) }
          end

          def to_s()
            content.to_s
          end
        end
      end
    end
  end
end

