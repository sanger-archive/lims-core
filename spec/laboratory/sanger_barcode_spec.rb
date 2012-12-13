# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/label_examples'

# Model requirements
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core::Laboratory

  describe SangerBarcode do
    let(:create_parameters) { {:value => "hello"} }
    it_behaves_like "label"
  end
end
