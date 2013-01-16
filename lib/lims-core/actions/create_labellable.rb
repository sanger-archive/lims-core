# create_labellable.rb
require 'lims/core/actions/action'

require 'lims/core/laboratory/labellable'

module Lims::Core
  module Actions
    class CreateLabellable
      include Action

      attribute :name, String, :required => true, :writer => :private, :initializable => true
      attribute :type, String, :required => true, :writer => :private, :initializable => true
      attribute :labels, Hash, :default => {}, :writer => :private, :initializable => true

      def _call_in_session(session)
        labellable = Laboratory::Labellable.new(:name => name,
                                                :type => type)

        labels.each { |position, label|
          created_label = Laboratory::Labellable::Label.new(:type => label["type"],
                                                    :value => label["value"])

          labellable[position]= created_label
        }

        session << labellable

        { :labellable => labellable, :uuid => session.uuid_for!(labellable) }
      end
    end
  end
  module Laboratory
    class Labellable
      Create = Actions::CreateLabellable
    end
  end
end
