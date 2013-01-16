# create_labellable.rb
require 'lims/core/actions/action'

require 'lims/core/laboratory/labellable'

module Lims::Core
  module Actions
    class CreateLabel
      include Action

      attribute :location, String, :required => true, :writer => :private, :initializable => true
      attribute :type, String, :required => true, :writer => :private, :initializable => true
      attribute :value, String, :required => true, :writer => :private, :initializable => true
      attribute :position, String, :required => true, :writer => :private, :initializable => true

      def _validate_parameters
        labellable = session.labellable[{:name=>location}]
        raise InvalidParameters, 
          "Labellable object is not exist with the given location: {#location}" if labellable.nil?
      end

      def _call_in_session(session)

        labellable = session.labellable[{:name=>location}]

        label = Laboratory::Labellable::Label.new(:type => type,
                                      :value => value)

        labellable[position]= label

        { :labellable => labellable, :uuid => session.uuid_for!(labellable) }
      end

    end
  end

  module Laboratory
    class Labellable
      Update = Actions::CreateLabel
    end
  end
end
