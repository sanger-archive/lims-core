# Spec requirements
require 'spec_helper'
require 'laboratory/aliquot_shared'

# Model requirements

require 'lims/core/laboratory/tube_rack'
require 'facets/array'

module Lims::Core
  module Laboratory
    shared_context "tube_rack factory" do
      include_context "aliquot factory"

      def new_tube_rack_with_samples(sample_nb=5, quantity=nil)
        TubeRack.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns).tap do |tube_rack|
          tube_rack.each_with_index do |slot, i|
            tube = Tube.new
            tube_rack[i] = tube
            1.upto(sample_nb) do |j|
              tube <<  new_aliquot(i,j,quantity)
            end
          end
        end
      end

      def new_empty_tube_rack()
        TubeRack.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns)
      end

      def new_empty_tube()
        Tube.new
      end

    end
  end
end
