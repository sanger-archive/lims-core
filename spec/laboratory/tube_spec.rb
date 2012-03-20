# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/located_examples'
require 'laboratory/receptacle_examples'
require 'laboratory/labellable_examples'

# Model requirements
require 'lims/core/laboratory/tube'

module Lims::Core::Laboratory
  describe Tube  do
    it_behaves_like "located" 
    it_behaves_like "receptacle"
    it_behaves_like "labellable"
  end
end
