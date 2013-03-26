# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'

require 'lims-core/laboratory/tube'

module Lims::Core
  module Laboratory
    class Tube::CreateTube
      include Actions::Action

      attribute :aliquots, Array, :default => []
      attribute :type, String, :required => false, :writer => :private
      attribute :max_volume, Numeric, :required => false, :writer => :private

      def initialize(*args, &block)
        @name = "Create Tube"
        super(*args, &block)
      end

      def _call_in_session(session)
        tube = Laboratory::Tube.new(:type => type, :max_volume => max_volume)
        session << tube
        aliquots.each do |aliquot|
          tube << Laboratory::Aliquot.new(aliquot)
        end
        { :tube => tube, :uuid => session.uuid_for!(tube) }
      end
    end
  end
  module Laboratory
    class Tube
      Create = CreateTube
    end
  end
end
