# create_labellable.rb
require 'lims/core/actions/action'

require 'lims/core/laboratory/labellable'

module Lims::Core
  module Actions
    class CreateLabel
      include Action

      attribute :labellable, Lims::Core::Laboratory::Labellable, :required => true, :writer => :private, :initializable => true
      attribute :type, String, :required => true, :writer => :private, :initializable => true
      attribute :value, String, :required => true, :writer => :private, :initializable => true
      attribute :position, String, :required => true, :writer => :private, :initializable => true

      def _validate_parameters
        raise InvalidParameters, 
          "Labellable object is not exist! We can not add label to it." if labellable.nil?
      end

      def _call_in_session(session)
        label = Laboratory::Labellable::Label.new(:type => type,
                                      :value => value)

        labellable[position] = label

        session << labellable

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
