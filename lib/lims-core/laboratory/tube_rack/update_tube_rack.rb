# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'
require 'lims-core/laboratory/tube_rack'

module Lims::Core
  module Laboratory
    # Update a tube rack by updating each of its tube type or quantity.
    class TubeRack::UpdateTubeRack
      include Actions::Action

      attribute :tube_rack, Laboratory::TubeRack, :required => true, :writer => :private
      attribute :aliquot_type, String, :required => false, :writer => :private
      attribute :aliquot_quantity, Numeric, :required => false, :writer => :private

      def _call_in_session(session)
        tube_rack.each do |tube|
          if tube
            tube.each do |aliquot|
              aliquot.type = aliquot_type if aliquot_type
              aliquot.quantity = aliquot_quantity if aliquot_quantity
            end
          end
        end
        {:tube_rack => tube_rack}
      end
    end
  end

  module Laboratory
    class TubeRack
      Update = UpdateTubeRack
    end
  end
end
