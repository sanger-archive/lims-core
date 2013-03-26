# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

require 'laboratory/plate_and_gel_shared'

#Model requirements
require 'lims-core/laboratory/gel/create_gel'

module Lims::Core
  module Laboratory
    shared_context "for empty gel" do
      subject do
        CreateGel.new(:store => store, :user => user, :application => application)  do |a,s|
          a.ostruct_update(dimensions)
        end
      end

      let (:gel_checker) do
        lambda do |gel|
          gel.each  { |w| w.should be_empty }
        end
      end
    end
    shared_context "for gel with a map of samples" do
      let(:windows_description) do
        {}.tap do |h|
          1.upto(number_of_rows) do |row|
            1.upto(number_of_columns) do |column|
              h[Laboratory::Gel.indexes_to_element_name(row-1, column-1)] = [{
                :sample => new_sample(row, column),
                :quantity => nil
              }]
            end
          end
        end
      end
      subject do
        CreateGel.new(:store => store, :user => user, :application => application)  do |a,s|
          a.ostruct_update(dimensions)
          a.windows_description = windows_description
        end
      end

      let (:gel_checker) do
        lambda do |gel|
          windows_description.each do |window_name, expected_aliquots|
            aliquots = gel[window_name]
            aliquots.size.should == 1
            aliquots.first.sample.should == expected_aliquots.first[:sample]
          end
        end
      end
    end

    shared_examples_for "creating a gel" do
      include_context "create object"
      it_behaves_like "an action"
      it "creates a gel when called" do
        result = subject.call()
        result.should be_a Hash

        gel = result[:gel]
        gel.number_of_rows.should == dimensions[:number_of_rows]
        gel.number_of_columns.should == dimensions[:number_of_columns]
        gel_checker[gel]

        result[:uuid].should == uuid
      end
    end

    shared_context "has gel dimension" do |row, col|
      let(:number_of_rows) { row }
      let(:number_of_columns) { col }
      let(:dimensions) {{ :number_of_rows => row, :number_of_columns => col }}
    end

    describe CreateGel do
      context "valid calling context" do
        let!(:store) { Persistence::Store.new() }
        include_context "plate or gel factory"
        include_context("for application",  "Test gel creation")

        include_context("has gel dimension", 8, 12)

        context do
          include_context "for empty gel"
          it_behaves_like('creating a gel')
        end
        context do
          include_context "for gel with a map of samples"
          it_behaves_like('creating a gel')
        end
      end
    end
  end
end
