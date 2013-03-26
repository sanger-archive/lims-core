# Spec requirements
require 'laboratory/spec_helper'
require 'labels/label_examples'

# Model requirements
require 'lims-core/labels/sanger_barcode'

module Lims::Core::Laboratory

  describe SangerBarcode do
    let(:create_parameters) { {:value => "hello"} }
    it_behaves_like "label"
  end
end
