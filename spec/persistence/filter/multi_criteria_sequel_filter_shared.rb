# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/page_shared'

require 'lims-core/persistence/filter/multi_criteria_filter'

module Lims::Core

shared_examples_for "filtrable" do |persistor_name|
  let(:ids) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,  15, 17] }
  let(:filter) { Persistence::MultiCriteriaFilter.new(:id => ids) }

  let(:persistor) { store.with_session { |s| filter.call(s.public_send(persistor_name)) } }
  let(:override_resource_number) { ids.size }
  it_behaves_like "paginable", persistor_name
end

end
