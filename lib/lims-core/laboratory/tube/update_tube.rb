# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-core/laboratory/tube'

module Lims::Core
  module Laboratory
    # Update a tube and set a new type and/or a new quantity to 
    # all its aliquots.
    class Tube::UpdateTube
      include Action

      # The tube to update
      attribute :tube, Laboratory::Tube, :required => true, :writer => :private
      # On update, all the aliquots in the tube will have the type
      # aliquot_type and the quantity aliquot_quantity.
      attribute :aliquot_type, String, :required => false, :writer => :private
      attribute :aliquot_quantity, Numeric, :required => false, :writer => :private 
      # The actual type of the tube, like Eppendorf.
      attribute :type, String, :required => false, :writer => :private
      attribute :max_volume, Numeric, :required => false, :writer => :private

      def _call_in_session(session)
        tube.type = type if type
        tube.max_volume = max_volume if max_volume
        tube.each do |aliquot|
          aliquot.type = aliquot_type unless aliquot_type.nil?
          aliquot.quantity = aliquot_quantity unless aliquot_quantity.nil?
        end
        {:tube => tube}
      end
    end
  end

  module Laboratory
    class Tube
      Update = Actions::UpdateTube
    end

    # As Tube and SpinColumn behave the same, update a spin column
    # redirects to update a tube action.
    class SpinColumn
      Update = Actions::UpdateTube
    end
  end
end
