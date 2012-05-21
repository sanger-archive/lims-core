# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/laboratory/tube'

module Lims::Core
  module Actions
    class CreateTube
      include Action

      %w(row column).each do |w|
        attribute :"#{w}_number",  Fixnum, :required => true, :gte => 0, :writer => :private
      end

      def initialize(*args, &block)
        @name = "Create Tube"
        super(*args, &block)
      end

      def _call_in_session(session)
        Laboratory::Tube.new()
      end
    end
  end
end
