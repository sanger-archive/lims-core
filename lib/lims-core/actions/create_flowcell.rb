#create_flowcell.rb
require 'lims/core/actions/action'

require 'lims/core/laboratory/flowcell'

module Lims::Core
  module Actions
    class CreateFlowcell
      include Action

      attribute :number_of_lanes, Fixnum, :required => true, :gte => 0, :writer => :private

      # @attribute [Hash<String>, Array<Hash>>] lanes_description
      # @example
      #   { "1" => [{ :sample => s1, :quantity => 2}, {:sample => s2}] }
      # # the keys are a String and start a 1 for the firt lane.
      attribute :lanes_description, Hash, :default => {}

      def _call_in_session(session)
        flowcell = Laboratory::Flowcell.new(:number_of_lanes => number_of_lanes)
        session << flowcell
        lanes_description.each do |lane_name, aliquots|
          aliquots.each do |aliquot|
            flowcell[lane_name.to_i-1] <<  Laboratory::Aliquot.new(aliquot)
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
