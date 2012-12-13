  shared_examples "requires" do |attribute|
    context "without #{attribute}" do
      let(:excluded_parameters) { [attribute] }
      it "'s not valid" do
        subject.valid?.should == false
      end
    end

  end

