# Spec requirements
require 'organization/spec_helper'
require 'organization/releasable_examples'

# Model requirements
require 'lims/core/organization/study'

module Lims::Core::Organization
  describe Study do
    it_behaves_like "releasable"
  end
end

