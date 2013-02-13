# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/laboratory/plate'
require 'lims/core/actions/container'

module Lims::Core
  module Actions
    class CreatePlate
      include Action
      include Container

      # @attribute [Hash<String, Array<Hash>>] wells_description
      # @example
      #   { "A1" => [{ :sample => s1, :quantity => 2}, {:sample => s2}] }
      attribute :wells_description, Hash, :default => {}
      # Type is the actual type of the plate, not the role in the order.
      attribute :type, String, :required => false, :writer => :private 

      def _call_in_session(session)
        plate = Laboratory::Plate.new(:number_of_columns => number_of_columns, 
                                      :number_of_rows => number_of_rows,
                                      :type => type)
        session << plate
        wells_description.each do |location, aliquots|
          aliquots.each do |aliquot|
            plate[location] <<  Laboratory::Aliquot.new(aliquot)
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
