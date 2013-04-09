# create_labellable.rb
require 'lims-core/actions/action'

require 'lims-core/labels/labellable'

module Lims::Core
  module Labels
    class CreateLabel
      include Actions::Action

      attribute :labellable, Lims::Core::Labels::Labellable, :required => true, :writer => :private, :initializable => true
      attribute :type, String, :required => true, :writer => :private, :initializable => true
      attribute :value, String, :required => true, :writer => :private, :initializable => true
      attribute :position, String, :required => true, :writer => :private, :initializable => true

      def _validate_parameters
        raise InvalidParameters, 
          "Labellable object is not exist! We can not add label to it." if labellable.nil?
      end

      def _call_in_session(session)
        label = Labels::Labellable::Label.new(:type => type,
                                      :value => value)

        labellable[position] = label

        session << labellable

        {:labellable => labellable}
      end

    end
  end

  module Labels
    class Labellable
      Update = CreateLabel
    end
  end
end
