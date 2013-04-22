# Spec requirements
require 'laboratory/spec_helper'


# Expect a create_parameters hash
shared_examples "label" do 
    context "to be valid" do
      let(:excluded_parameters) { [] }
      subject { described_class.new(create_parameters - excluded_parameters) }
      it  "valid" do
        subject.valid?.should == true
      end
      it_behaves_like "requires", :value

      its(:type) { should be_a(String) }
    end
end

