require 'spec_helper'

require 'lims/core/persistence/store'
require 'lims/core/persistence/session'

shared_context "create object" do
  let (:uuid) { "00000000-1111-2222-333333333333" }
  before do 
    Lims::Core::Persistence::Session.any_instance.tap do |session|
      session.stub(:save)
      session.stub(:uuid_for!) { uuid }
    end
  end
end


