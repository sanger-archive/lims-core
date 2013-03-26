# Spec requirements
require 'laboratory/spec_helper'
require 'laboratory/container_examples'

# Model requirements
require 'lims-core/laboratory/tag_group'

module Lims::Core::Laboratory
  describe TagGroup do
    let(:sequence_1) { "AAA" }
    let(:sequence_2) { "CCC" }
    let(:oligo_1) { Oligo.new(sequence_1) }
    let(:oligo_2) { Oligo.new(sequence_2) }
    context "to be valid" do
      pending "validation not implemented yet" do
      it "should contains each oligo sequence once. " do
        2.times { subject << oligo_1 }

        subject.valid?.should be_false
      end
      it "requires a name" do
        described_class.new(:name => nil)
      end
      end
    end
    context "empty" do
      subject { described_class.new(:name => "my group") }
      it_behaves_like "a container", Oligo
      it "can have an oligo added" do
        expect { subject << Oligo.new(sequence_1)}.to change { subject.size }.by(1)
      end
    end
    context "non empty" do
      subject { described_class.new(:name => "my group").tap do |g|
        g << Oligo.new(sequence_1) << Oligo.new(sequence_2)
      end
      }

      it_behaves_like "a container", Oligo
      it "can have an oligo added" do
        expect { subject << oligo_1 << oligo_2 }
      end

      it "can be indexed" do
        subject[0].should == oligo_1
        subject[1].should == oligo_2
      end
    end
  end
end

