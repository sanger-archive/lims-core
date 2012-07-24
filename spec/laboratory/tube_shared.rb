# Spec requirements
require 'spec_helper'

# Model requirements

require 'lims/core/laboratory/tube'
require 'facets/array'

L=Lims::Core::Laboratory
def new_sample(i=1)
  L::Sample.new(:name => "Sample ##{i}")
end

def new_aliquot(i=1)
  L::Aliquot.new(:sample => new_sample(i))
end

module Lims::Core
  module Laboratory
    shared_context "tube factory" do
      def new_tube_with_samples(sample_nb=5)
        Tube.new.tap do |tube|
          1.upto(sample_nb) do |i|
            tube <<  new_aliquot(i)
          end
        end
      end

      def new_empty_tube
        Tube.new
      end
    end
  end
end
