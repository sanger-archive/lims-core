# Spec requirements
require 'spec_helper'

# Model requirements

require 'lims-core/laboratory/flowcell'

shared_context "flowcell factory" do
  def new_flowcell_with_samples(sample_nb=5)
    Flowcell.new.tap do |flowcell|
      flowcell.each_with_index do |lane, i|
        1.upto(sample_nb) do |j|
          lane << Aliquot.new(:sample => "Sample ##{i+1}/#{j+1}")
        end
      end
    end
  end

  def new_empty_flowcell
    Flowcell.new
  end
end
