# Spec requirements
require 'laboratory/spec_helper'

Lab=Lims::Core::Laboratory

shared_examples "add contents" do
  it "can have a chemical content added to it" do
    expect {
      subject << [ Lab::Aliquot.new(:type => 1), Lab::Aliquot.new(:type => "new type") ]
    }.to change{subject.size}.by(2)
  end

  it "can have an aliquot added to it" do
    expect {
      subject << Lab::Aliquot.new(:type => "new type")
    }.to change{subject.size}.by(1)
  end
end


shared_examples "can have a fraction of its content taken" do |volume, aliquot_quantity, fraction_taken, volume_in_target, aliquot_quantity_in_target, volume_left, aliquot_quantity_left |
  context "take #{fraction_taken} of #{volume}/#{aliquot_quantity}" do
    subject { described_class.new.tap { |r| r << Lab::Aliquot.new(:quantity=>aliquot_quantity) << Lab::Aliquot.new(:quantity => volume, :type => Lab::Aliquot::Solvent) } } 
    let(:aliquot) { subject[0] }
    let!(:taken ) { described_class.new << subject.take_fraction(fraction_taken) }

    it "leaves the correct volume" do
      subject.volume.should == volume_left
    end
    it "leaves the correct aliquot quantity" do
      aliquot.quantity.should == aliquot_quantity_left
    end

    it "gives the correct volume to the target" do
      taken.volume.should == volume_in_target
    end
    it "gives the correct aliquot quantity to the target" do
      taken[0].quantity.should == aliquot_quantity_in_target
    end
  end
end

shared_examples "can have its content taken" do |volume, aliquot_quantity, amount_taken, volume_in_target, aliquot_quantity_in_target, volume_left, aliquot_quantity_left |
  context "take #{amount_taken} of #{volume}/#{aliquot_quantity}" do
    subject { described_class.new.tap { |r| r << Lab::Aliquot.new(:quantity=>aliquot_quantity) << Lab::Aliquot.new(:quantity => volume, :type => Lab::Aliquot::Solvent) } } 
    let(:aliquot) { subject[0] }
    let!(:taken ) { described_class.new << subject.take_amount(amount_taken) }

    it "leaves the correct volume" do
      subject.volume.should == volume_left
    end

    it "leaves the correct aliquot quantity" do
      aliquot.quantity.should == aliquot_quantity_left
    end

    it "gives the correct volume to the target" do
      taken.volume.should == volume_in_target
    end

    it "gives the correct aliquot quantity to the target" do
      taken[0].quantity.should == aliquot_quantity_in_target
    end
  end
end

shared_examples "receptacle" do
  context "when first created" do
    its(:size) { should eq(0) }
    it { should be_empty}
    include_examples "add contents"
  end

  context "#take" do
    context "unknown volume" do
      context "known amount" do
        it_behaves_like "can have its content taken", nil, 5, 20.0, nil, nil, nil, 5
        it_behaves_like "can have its content taken", nil, nil, 20.0, nil, nil, nil, nil
      end
      context "unknow amount" do
        it_behaves_like "can have its content taken", nil, 5, nil, nil, nil, nil, 5
        it_behaves_like "can have its content taken", nil, nil, nil, nil, nil, nil, nil
      end
    end
    context "known volume" do
      context "known amount" do
        it_behaves_like "can have its content taken", 100, 5, 20.0, 20, 1, 80, 4
        it_behaves_like "can have its content taken", 100, nil, 20.0, 20, nil, 80, nil
        it_behaves_like "can have its content taken", 100, 5, 200.0, 100, 5, 0, 0 
      end
      context "unknow amount" do
        it_behaves_like "can have its content taken", 100, 5, nil, nil, nil, 100,5
        it_behaves_like "can have its content taken", 100, nil, nil, nil, nil, 100, nil
      end
    end
  end
  context "#take fraction" do
    context "unknown volume" do
      context "known amount" do
        it_behaves_like "can have a fraction of its content taken", nil, 5, 0.20, nil, 1, nil, 4
        it_behaves_like "can have a fraction of its content taken", nil, nil, 0.20, nil, nil, nil, nil
      end
      context "unknow amount" do
        it_behaves_like "can have a fraction of its content taken", nil, 5, nil, nil, nil, nil, 5
        it_behaves_like "can have a fraction of its content taken", nil, nil, nil, nil, nil, nil, nil
      end
    end
    context "known volume" do
      context "known amount" do
        it_behaves_like "can have its content taken", 100, 5, 20.0, 20, 1, 80, 4
        it_behaves_like "can have its content taken", 100, nil, 20.0, 20, nil, 80, nil
      end
      context "unknow amount" do
        it_behaves_like "can have its content taken", 100, 5, nil, nil, nil, 100, 5
        it_behaves_like "can have its content taken", 100, nil, nil, nil, nil, 100, nil
      end
    end
  end



  context "with a chemical content", :focus => true do
    let(:aliquot) { Lab::Aliquot.new(:quantity=>5) }
    let(:solvent) {  Lab::Aliquot.new(:quantity => 100, :type => Lab::Aliquot::Solvent) }
    subject { described_class.new.tap { |r| r << solvent << aliquot } }

    include_examples "add contents"
    it { should_not be_empty }

    it "has the correct volume" do
      subject.volume.should == solvent.quantity
    end

    it "has the correct quantitie" do
      subject.quantity(Lab::Aliquot::Volume).should == 100
      subject.quantity(Lab::Aliquot::AmountOfSubstance).should == 5
    end

    context  "can be mixed" do
      context "with a substance" do
        before(:all) { subject << Lab::Aliquot.new(:quantity => 5) }
        it { subject.quantity(Lab::Aliquot::AmountOfSubstance).should == 10 }
        it { subject.quantity(Lab::Aliquot::Volume).should == 100 }
      end
    end
    context "with a solvent" do
      before(:all) { (subject << Lab::Aliquot.new(:quantity => 50, :type => Lab::Aliquot::Solvent)) }
      it { subject.quantity(Lab::Aliquot::AmountOfSubstance).should == 5 }
      it { subject.quantity(Lab::Aliquot::Volume).should == 150 }
    end

  end

  context "with an unknow quantity" do
    let(:aliquot) { Lab::Aliquot.new(:quantity=>5) }
    let(:solvent) {  Lab::Aliquot.new(:quantity => 100, :type => Lab::Aliquot::Solvent) }
    subject { described_class.new.tap { |r| r << aliquot } }
    its(:volume) { should == nil }
  end

end

