# create_labellable.rb
require 'lims/core/actions/action'

require 'lims/core/laboratory/labellable'

module Lims::Core
  module Actions
    class CreateLabel
      include Action

      attribute :name, String, :required => true, :write => :private, :initializable => true
      attribute :type, String, :required => true, :write => :private, :initializable => true
      attribute :labels, Hash, :default => {}, :write => :private, :initializable => true

      def _call_in_session(session)
        label = Laboratory::Label.new(:name => name,
                                                :type => type,
                                                :content => content)
        session << labellable

        { :label => label, :uuid => session.uuid_for!(label) }
      end
    end
  end
  module Laboratory
    class Labellable
      # TODO ke4 figure it out what is the proper definition
      Create = Actions::CreateLabel
    end
  end
end
