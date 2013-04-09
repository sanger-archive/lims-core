# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims-core/actions/action'
require 'lims-core/organization/batch'

module Lims::Core
  module Organization
    class Batch
      class CreateBatch
        include Actions::Action

        attribute :process, String, :required => false, :writer => :private
        attribute :kit, String, :required => false, :writer => :private

        def _call_in_session(session)
          batch = Batch.new({
              :process => process,
              :kit => kit 
            })
          session << batch
          {:batch => batch, :uuid => session.uuid_for!(batch)}
        end

      end
    end
    class Batch
      Create = CreateBatch
    end
  end
end
