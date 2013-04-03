
# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-core/laboratory/plate'

module Lims::Core
  module Laboratory
    # Update a plate and set a new type and/or a new quantity to 
    # all its aliquots.
    class Plate
      class UpdatePlate
        include Actions::Action

        # The plate to update
        attribute :plate, Laboratory::Plate, :required => true, :writer => :private
        attribute :aliquot_type, String, :required => false, :writer => :private
        attribute :aliquot_quantity, Numeric, :required => false, :writer => :private 
        # Type is the actual type of the plate, not the role in the order.
        attribute :type, String, :requried => false, :writer => :private

        def _call_in_session(session)
          plate.type = type if type
          plate.each do |well|
            well.each do |aliquot|
              aliquot.type = aliquot_type if aliquot_type
              aliquot.quantity = aliquot_quantity if aliquot_quantity
            end
          end
          {:plate => plate}
        end
      end
    end
    end

  module Laboratory
    class Plate
      Update = UpdatePlate
    end
  end
end
