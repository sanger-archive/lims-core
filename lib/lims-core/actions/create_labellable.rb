# create_labellable.rb
require 'lims/core/actions/action'

require 'lims/core/laboratory/labellable'

module Lims::Core
  module Actions
    class CreateLabellable
      include Action

      attribute :name, String, :required => true, :write => :private, :initializable => true
      attribute :type, String, :required => true, :write => :private, :initializable => true
      #TODO ke4 maybe it should be label instead of content?
      attribute :content, Hash, :default => {}, :write => :private, :initializable => true

      def _call_in_session(session)
        labellable = Laboratory::Labellable.new(:name => name,
                                                :type => type)
        session << labellable
        
        #TODO ke4 add content creation
        labellable.positions.concat(content.keys)
        labellable.labels.concat(content.values)
        
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
