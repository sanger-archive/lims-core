# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'
require 'lims-core/organization/batch'

module Lims::Core
  module Organization
    class Batch
      class CreateBatch
        include Actions::Action

        attribute :process, String, :required => false, :writer => :private

        def _call_in_session(session)
          batch = Organization::Batch.new(:process => process)
          session << batch
          {:batch => batch, :uuid => session.uuid_for!(batch)}
        end

      end
    end
  end
  module Organization
    class Batch
      Create = CreateBatch
    end
  end
end
