# Spec requirements
require 'laboratory/spec_helper'

module Lims::Core::Laboratory
  # A Container contains 'contained' 
  module Container
  end
end
shared_examples "a container" do |contained|
  it { subject.respond_to?(:each).should be_true }
  it "has many 'contained' objects" do
    subject.each do |content|
      content.should be_a(contained)
    end
  end
  it "can iterate on 'contained' objects" do
  end
  it "has a number of 'contained' object" do
    subject.size
  end
end
