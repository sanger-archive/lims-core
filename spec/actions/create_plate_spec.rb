# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

require 'laboratory/plate_and_gel_shared'

#Model requirements
require 'lims/core/actions/create_plate'

module Lims::Core
  module Actions
    shared_context "for empty plate" do
      subject do
        CreatePlate.new(:store => store, :user => user, :application => application)  do |a,s|
          a.ostruct_update(dimensions)
          a.type = plate_type
        end
      end

      let (:plate_checker) do
        lambda do |plate|
          plate.each  { |w| w.should be_empty }
        end
      end
    end
    shared_context "for plate with a map of samples" do
      let(:wells_description) do
        {}.tap do |h|
          1.upto(number_of_rows) do |row|
            1.upto(number_of_columns) do |column|
              h[Laboratory::Plate.indexes_to_element_name(row-1, column-1)] = [{
                :sample => new_sample(row, column),
                :quantity => nil
              }]
            end
          end
        end
      end
      subject do
        CreatePlate.new(:store => store, :user => user, :application => application)  do |a,s|
          a.ostruct_update(dimensions)
          a.wells_description = wells_description
          a.type = plate_type
        end
      end

      let (:plate_checker) do
        lambda do |plate|
          wells_description.each do |well_name, expected_aliquots|
            aliquots = plate[well_name]
            aliquots.size.should == 1
            aliquots.first.sample.should == expected_aliquots.first[:sample]
          end
        end
      end
    end

    shared_examples_for "creating a plate" do
      include_context "create object"
      it_behaves_like "an action"
      it "creates a plate when called" do
        result = subject.call()
        result.should be_a Hash

        plate = result[:plate]
        plate.number_of_rows.should == dimensions[:number_of_rows]
        plate.number_of_columns.should == dimensions[:number_of_columns]
        plate.type.should == plate_type
        plate_checker[plate]

        result[:uuid].should == uuid
      end
    end

    shared_context "has plate dimension" do |row, col|
      let(:number_of_rows) { row }
      let(:number_of_columns) { col }
      let(:dimensions) {{ :number_of_rows => row, :number_of_columns => col }}
    end

    describe CreatePlate do
      context "valid calling context" do
        let!(:store) { Persistence::Store.new() }
        include_context "plate or gel factory"
        include_context("for application",  "Test plate creation")

        include_context("has plate dimension", 8, 12)
        let(:plate_type) { mock(:plate_type) }

        context do
          include_context "for empty plate"
          it_behaves_like('creating a plate')
        end
        context do
          include_context "for plate with a map of samples"
          it_behaves_like('creating a plate')
        end
      end
    end
  end
end
