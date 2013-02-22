module Lims::Core
  module Laboratory
    shared_context "aliquot factory" do
      def new_sample(i=1, j=1)
        Sample.new(["Sample", i, j].compact.conjoin(" ", "/"))
      end

      def new_aliquot(i=nil, j=nil, q=nil)
        sample = Sample
        aliquot = Aliquot.new(:sample => new_sample(i,j))
        aliquot.quantity = q if q
        aliquot
      end
    end
  end
end
