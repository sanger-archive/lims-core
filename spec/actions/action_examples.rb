require 'actions/spec_helper'

shared_examples "an action" do
  context "to be valid" do
    its(:user) { should_not be_nil }
    its(:application) { should_not be_nil }
    its(:application) { should_not be_empty }
    its(:store) { should_not be_nil }

    it { should respond_to(:call) }
    it { should respond_to(:revert) }

    xit { subject.valid?.should be_true }
  end

  context "well implemented" do
  end
end

shared_context "for application" do |application_string|
        let(:user) { mock(:user) }
        let(:application) { application_string}
end
