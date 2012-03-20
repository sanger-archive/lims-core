# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/located_examples'
require 'laboratory/container_examples'
require 'laboratory/labellable_examples'

# Model requirements
require 'lims/core/laboratory/plate'

module Lims::Core::Laboratory
  describe Plate  do
    it_behaves_like "located" 
    context "contains wells" do
      it_behaves_like "a container", Well
    end
    it_behaves_like "labellable"
  end
end
