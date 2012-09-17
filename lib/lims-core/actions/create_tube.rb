# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/laboratory/tube'

module Lims::Core
  module Actions
    class CreateTube
      include Action

      def initialize(*args, &block)
        @name = "Create Tube"
        super(*args, &block)
      end

      def _call_in_session(session)
        tube=Laboratory::Tube.new()
        session << tube
        { :tube => tube, :uuid => session.uuid_for!(tube) }
      end
    end
  end
  module Laboratory
    class Tube
      Create=Actions::CreateTube
    end
  end
end
