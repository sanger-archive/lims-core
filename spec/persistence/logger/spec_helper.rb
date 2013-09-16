require 'spec_helper'

require 'lims-core/persistence/logger/store'

RSpec.configure do |c|
  c.filter_run_excluding :logger => true
end
