require 'actions/spec_helper'

require 'actions/action_examples'

module Lims::Core::Action
  describe "Plate::Stamping", :plate => true, :laboratory => true do
    pending "Not Implemented" do
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
  end

  describe "Plate::Pooling", :plate => true, :laboratory => true do
    pending "Not implemented" do
      it_behaves_like "an action"
      context "from a plate to another plate" do
        it "transfers wells to other plate grouped by pool"
      end
    end
  end

  describe "Plate::Rotating", :plate => true, :laboratory => true do
    pending "Not implemented" do
      it_behaves_like "an action"
      context "from a plate to another plate" do
        context "if possible" do
          it "transfers the well in transposed way" 
        end
        context "if not possible" do
          it "fails"
        end
      end
      pending "Not implemented" do
      end

      describe "Plate::Cherrypicking", :plate => true, :laboratory => true do
        pending "Not implemented" do
          context "from many plates to one plate" do
            it "transfers some wells to the destination plate"
          end 
        end
      end

      describe "Plate::Tagging", :plate => true, :laboratory => true do
      end

      describe "plate to tubes" do
      end
    end
  end
end
