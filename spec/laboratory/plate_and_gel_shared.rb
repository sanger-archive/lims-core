# Spec requirements
require 'spec_helper'

# Model requirements

require 'lims/core/laboratory/plate'
require 'facets/array'

module Lims::Core
  module Laboratory
    shared_context "plate or gel factory" do
      def new_plate_or_gel_with_samples(asset_to_create, sample_nb=5)
        asset_to_create.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns).tap do |asset|
          asset.each_with_index do |w, i|
            1.upto(sample_nb) do |j|
              w <<  new_aliquot(i,j)
            end
          end
        end
      end

      def new_empty_plate_or_gel(asset_to_create)
        asset_to_create.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns)
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
