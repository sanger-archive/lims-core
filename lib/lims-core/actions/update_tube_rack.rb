# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'
require 'lims/core/laboratory/tube_rack'

module Lims::Core
  module Actions
    class UpdateTubeRack
      include Action

      attribute :tube_rack, Laboratory::TubeRack, :required => true, :writer => :private
      attribute :aliquot_type, String, :required => false, :writer => :private
      attribute :aliquot_quantity, Numeric, :required => false, :writer => :private

      def _call_in_session(session)
        tube_rack.each do |tube|
          tube.each do |aliquot|
            aliquot.type = aliquot_type unless aliquot_type.nil?
            aliquot.quantity = aliquot_quantity unless aliquot_quantity.nil?
          end
        end
        {:tube_rack => tube_rack}
      end
    end
  end

  module Laboratory
    class TubeRack
      Update = Actions::UpdateTubeRack
    end
  end
end
