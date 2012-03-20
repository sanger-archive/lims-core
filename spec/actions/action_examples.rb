require 'actions/spec_helper'

shared_examples "an action" do
  it "requires a user"
  it "requires a title"

  # @todo  move in Action::Base spec
  it "must save modified objects"
  it "must create a session with user an title"
end
