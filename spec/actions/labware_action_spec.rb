require 'actions/spec_helper'

require 'actions/action_examples'

module Lims::Core::Action
  describe "Plate::Stamping" do
    it_behaves_like "an action"
    context "from a plate to another plate" do
      context "to another plate" do
        it "transfers all the wells to the other plate"
      end

      context "to many plates" do
        it "fails"
      end
    end 
  end

  describe "Plate::Pooling" do
    it_behaves_like "an action"
    context "from a plate to another plate" do
      it "transfers wells to other plate grouped by pool"
    end
  end

  describe "Plate::Rotating" do
    it_behaves_like "an action"
    context "from a plate to another plate" do
      context "if possible" do
        it "transfers the well in transposed way" 
      end
      context "if not possible" do
        it "fails"
      end
    end
  end

  describe "Plate::Cherrypicking" do
    context "from many plates to one plate" do
      it "transfers some wells to the destination plate"
    end 
  end

  describe "Plate::Tagging" do
  end

  describe "plate to tubes" do
  end
end

