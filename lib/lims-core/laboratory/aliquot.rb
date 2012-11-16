# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en  
require 'common'


require 'lims/core/laboratory/sample'
require 'lims/core/laboratory/oligo'
require 'lims/core/resource'

module Lims::Core
  module Laboratory
    # An aliquot represent the fraction of identical chemical substance inside a receptacle.
    # it should have:
    # 1. A receptacle
    # 1. A quantity  => volume, weight, moles?
    # 2. An owner (Order?)
    # 3. One or more constituents (sample, tags).
    # 4. A type/shape (gel, library, sample  etc...)
    # Constituents inside an aliquot are bound together, i.e. :
    # - "mixing" sample and tag in a tube without any processing will probably results
    # in a receptacle containing two aliquots, one representing the tag and the other
    # one the sample.
    # - "tagging" a sample with a oligo will result in a receptacle containing one aliquot
    #   representing the tagged sample (the oligo and the sample are bound together).
    # At the moment, rather than allowing an aliquot to have many constituents (in a free form way),
    # an aliquot can be formed of at least a {Laboratory::Sample sample}, a {Laboratory::Oligo tag} and  or a {Laboratory::BaitLibrary bait library}.
    class Aliquot
      include Resource
      attribute :sample, Sample
      attribute :tag, Oligo
      # @todo add a unit to quantity
      attribute :quantity, Numeric, :required=> true, :gte => 0

      # the form of the chemical substance, like library, sample etc ...
      attribute :type, String # Subclass ?

      #validates_presence_of :quantity
      #validates_numericalness_of :quantity, :gte => 0

      def take_fraction(fraction)
        new = self.class.new(attributes)
        if quantity
          new_quantity = quantity*fraction
          self.quantity -= new_quantity
          new.quantity = new_quantity
        end
        return new
      end
    end
  end
end
