# Spec requirements
require 'spec_helper'

# Model requirements

require 'lims/core/laboratory/plate'
require 'facets/array'

module Lims::Core
  module Laboratory
    shared_context "plate factory" do
      def new_plate_with_samples(sample_nb=5)
        Plate.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns).tap do |plate|
          plate.each_with_index do |well, i|
            1.upto(sample_nb) do |j|
              well <<  new_aliquot(i,j)
            end
          end
        end
      end

      def new_empty_plate()
        Plate.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns)
      end

      def new_sample(i=1, j=1)
        Sample.new(["Sample", i, j].compact.conjoin(" ", "/"))
      end

      def new_aliquot(i=nil, j=nil)
        sample = Sample
          Aliquot.new(:sample => new_sample(i,j))
      end

    end
  end
end
