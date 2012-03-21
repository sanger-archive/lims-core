# Spec requirements
require 'laboratory/spec_helper'

shared_examples "a container" do |contained|
  it { subject.should respond_to(:each) }
  it { subject.should respond_to(:size) }

  it "has many 'contained' objects" do
    subject.each do |content|
      content.should be_a(contained)
    end
  end
end
