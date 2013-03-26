# Spec requirements
require 'laboratory/located_examples'
require 'laboratory/receptacle_examples'
require 'labels/labellable_examples'

# Model requirement
require 'lims-core/laboratory/spin_column'

module Lims::Core::Laboratory
  describe SpinColumn  do
    it_behaves_like "located" 
    it_behaves_like "receptacle"
    it_behaves_like "labellable"
  end
end
