# Spec requirements
require 'persistence/sequel/spec_helper'
  require 'lims-core/persistence/filter/multi_criteria_filter'


shared_examples_for "paginable resource" do |persistor_name|
  let(:persistor) {  store.with_session { |session| session.send(persistor_name) } }
  it_behaves_like "paginable"
end

shared_examples_for "paginable" do
  let(:resource_number) { override_resource_number rescue 25 }
  context "no resources" do
    context "#persistor" do
      subject { persistor }
      its(:count) { should == 0 }
    end

    context "#slice" do
      subject {  persistor.slice(0, 10) } 

      it "is empty" do
        subject.to_a.size == 0
      end
    end


  end

  context "with many resources" do
    let!(:resources) {
      [].tap do |l|
      store.with_session do |session|
        1.upto(25) do |i|
          resource = constructor.call(i)
          session << resource
          l << resource
        end
      end
      end
    }
    context "#persistor" do
      subject { persistor }
      its(:count) { should == resource_number }
    end
    context "#slice" do
      subject {
        persistor.slice(0, 10)
      }
      it "returns the correct number of resource" do
        subject.to_a.size.should== 10
      end

      it "iterate over all" do
        _resources = Array.new(resources)
        subject.each  do |resource|
          resource == resources.shift
        end
      end

    end
    context "#too big slice" do
      subject {
        persistor.slice(0, 30)
      }
      it "returns the correct number of resource" do
        subject.to_a.size.should== resource_number
      end
    end

  end
end
