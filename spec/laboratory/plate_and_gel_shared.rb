# Spec requirements
require 'spec_helper'
require 'laboratory/aliquot_shared'

# Model requirements

require 'lims/core/laboratory/plate'
require 'facets/array'

module Lims::Core
  module Laboratory
    shared_context "plate or gel factory" do
      include_context "aliquot factory"

      def new_plate_with_samples(sample_nb=5, quantity=nil)
        new_plate_or_gel_with_samples(Plate, sample_nb, quantity)
      end

      def new_gel_with_samples(sample_nb=5, quantity=nil)
        new_plate_or_gel_with_samples(Gel, sample_nb, quantity)
      end

      def new_plate_or_gel_with_samples(asset_to_create, sample_nb, volume=100, quantity=nil)
        asset_to_create.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns).tap do |asset|
          asset.each_with_index do |w, i|
            1.upto(sample_nb) do |j|
              w <<  new_aliquot(i,j,quantity)
            end
            w << Aliquot.new(:type => Aliquot::Solvent, :quantity => volume) if volume
          end
        end
      end

      def new_empty_plate
        new_empty_plate_or_gel(Plate)
      end

      def new_empty_gel
        new_empty_plate_or_gel(Gel)
      end

      def new_empty_plate_or_gel(asset_to_create)
        asset_to_create.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns)
      end

    end
  end
end
