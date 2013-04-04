# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'
require 'lims/core/organization/batch'

module Lims::Core
  module Actions
    class UpdateBatch
      include Action

      attribute :batch, Organization::Batch, :required => true, :writer => :private
      attribute :process, String, :required => false, :writer => :private
      attribute :kit, String, :required => false, :writer => :private

      def _call_in_session(session)
        batch.process = process if process
        batch.kit = kit if kit
        {:batch => batch}
      end
    end
  end

  module Organization
    class Batch
      Update = Actions::UpdateBatch
    end
  end
end
