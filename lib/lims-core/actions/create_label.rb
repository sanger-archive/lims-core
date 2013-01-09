# create_labellable.rb
require 'lims/core/actions/action'

require 'lims/core/laboratory/labellable'

module Lims::Core
  module Actions
    class CreateLabel
      include Action

      attribute :name, String, :required => true, :write => :private, :initializable => true
      attribute :type, String, :required => true, :write => :private, :initializable => true
      attribute :label_type, String, :required => true, :write => :private, :initializable => true
      attribute :value, String, :required => true, :write => :private, :initializable => true
      attribute :position, String, :required => true, :write => :private, :initializable => true

      def _call_in_session(session)
        debugger
        labellable = session.labellable[{:uuid=>name}]
        unless labellable.nil?
          label = Laboratory::Label.new(:type => label_type,
                                        :value => value)
          session << label

          labellable.update_label(position, label)

          session << labellable

          { :label => label, :uuid => session.uuid_for!(label) }
        else
          false
        end
      end
    end
  end
  module Laboratory
    class Labellable
      Update = Actions::CreateLabel
    end
  end
end
