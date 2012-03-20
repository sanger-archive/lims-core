# Spec requirements
require 'spec_helper'

# Model requirements

require 'lims/core/laboratory/flowcell'
require 'facets/array'

module Lims::Core
  module Laboratory
    shared_context "flowcell factory" do
      def new_flowcell_with_samples(sample_nb=5)
        Flowcell.new.tap do |flowcell|
          flowcell.each_with_index do |lane, i|
            1.upto(sample_nb) do |j|
              lane <<  new_aliquot(i,j)
            end
          end
        end
      end

      def new_empty_flowcell
        Flowcell.new
      end

      def new_sample(i=1, j=1)
        ["Sample", i, j].compact.conjoin(" ", "/")
      end

      def new_aliquot(i=nil, j=nil)
        sample = Sample
          Aliquot.new(:sample => new_sample(i,j))
      end

    end
  end
end
