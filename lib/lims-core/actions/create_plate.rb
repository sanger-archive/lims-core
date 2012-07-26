# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/laboratory/plate'

module Lims::Core
  module Actions
    class CreatePlate
      include Action

      %w(row column).each do |w|
        attribute :"#{w}_number",  Fixnum, :required => true, :gte => 0, :writer => :private
      end
      # @attribute [Hash<String, Array<Hash>>] wells_description
      # @example
      # { "A1" => [{ :sample => s1, :quantity => 2}, {:sample => s2}] }
      attribute :wells_description, Hash, :default => {}

      def _call_in_session(session)
        plate = Laboratory::Plate.new(:column_number => column_number, :row_number => row_number)
        session << plate
        wells_description.each do |well_name, aliquots|
          aliquots.each do |aliquot|
            plate[well_name] <<  Laboratory::Aliquot.new(aliquot)
          end
        end
        { :plate => plate, :uuid => session.uuid_for!(plate) }
      end
    end
  end
  module Laboratory
    class Plate
      Create = Actions::CreatePlate
    end
  end
end
