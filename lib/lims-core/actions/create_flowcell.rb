#create_flowcell.rb
require 'lims/core/actions/action'

require 'lims/core/laboratory/flowcell'

module Lims::Core
  module Actions
    class CreateFlowcell
      include Action

      # @attribute [Hash<String, Array<Hash>>] lanes_description
      # @example
      # { 1 => [{ :sample => s1, :quantity => 2}, {:sample => s2}] }
      attribute :lanes_description, Hash, :default => {}

      def _call_in_session(session)
        flowcell = Laboratory::Flowcell.new
        session << flowcell
        lanes_description.each do |lane_id, aliquots|
          aliquots.each do |aliquot|
            flowcell[lane_id] <<  Laboratory::Aliquot.new(aliquot)
          end
        end
        { :flowcell => flowcell, :uuid => session.uuid_for!(flowcell) }
      end
    end
  end
  module Laboratory
    class Flowcell
      Create = Actions::CreateFlowcell
    end
  end
end
