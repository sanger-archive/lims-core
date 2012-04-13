# Spec requirements
require 'laboratory/spec_helper'

Lab=Lims::Core::Laboratory

shared_examples "add contents" do
  it "can have a chemical content added to it" do
    expect {
      subject << [mock(:aliquot), mock(:aliquot)]
    }.to change{subject.size}.by(2)
  end

  it "can have an aliquot added to it" do
    expect {
      subject << mock(:aliquot)
    }.to change{subject.size}.by(1)
  end
end

shared_examples "receptacle" do
  context "when first created" do
    its(:size) { should eq(0) }
    it { should be_empty}
    include_examples "add contents"
  end

  context "with a chemical content" do
    subject { described_class.new.tap { |r| r << Lab::Aliquot.new(:quantity=>10) } }

    include_examples "add contents"
    it { should_not be_empty }

    it "can have a part of its content taken" do
      expect {
        subject.take_fraction(0.3).should be_kind_of(Array)
      }.to change {subject[0].quantity}.by(-3)
    end

    context "after having all of its content taken", :wip => true do
      before(:each) { subject.take() }
      its(:content) { should be_empty }
    end
  end
end

