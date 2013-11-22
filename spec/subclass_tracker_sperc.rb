require 'spec_helper'

require 'lims-core/subclass_tracker'


module SubclassTrackerTest
  class A
    extend  Lims::Core::SubclassTracker
  end

  class B < A
  end

  class B2 < A
  end

  class C < B
  end

  module M
    extend Lims::Core::SubclassTracker
  end

  class N
    include M
  end

  class N2
    include M
  end

  class O < N
  end

  class O2 < N2
  end

  describe Lims::Core::SubclassTracker do
    context "track classes" do
      subject { A }

      it "responds to subclasses" do
        subject.should respond_to(:subclasses)
      end

      it "list its children" do
        subject.subclasses.should == [B, B2,  C]
      end
    end

    context "track modules" do
      subject { M }
      it "responds to subclasses" do
        subject.should respond_to(:subclasses)
      end

      it "list its children" do
        subject.subclasses.should == [N, N2, O, O2]
      end
    end
  end
end
