# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-core/laboratory/plate'

module Lims::Core
  module Laboratory
    class TagWells
      include Actions::Action

      attribute :plate, Laboratory::Plate, :writer => :private
      attribute :well_to_tag_map, Hash, :writer => :private
      def _call_in_session(session)
        well_to_tag_map.each do |well_name, tag| 
          well = plate[well_name]
          well.each do |aliquot|
            aliquot.tag = tag
          end
        end
      end
    end
  end
end
