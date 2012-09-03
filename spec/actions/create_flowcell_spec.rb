# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

require 'laboratory/flowcell_shared'

#Model requirement
require 'lims/core/actions/create_flowcell'

module Lims::Core
  module Actions

    shared_context "for empty flowcell" do
      subject do
        CreateFlowcell.new(:store => store, :user => user, :application => application)
      end

      let (:flowcell_checker) do
        lambda do |flowcell|
          flowcell.each { |lane| lane.should be_empty }
        end
      end
    end
    
    shared_examples_for "creating a flowcell" do
      include_context "create object"
      it_behaves_like "an action"
      it "creates a flowcell when called" do
        result = subject.call()
        result.should be_a Hash

        flowcell = result[:flowcell]
        flowcell_checker[flowcell]

        result[:uuid].should == uuid
      end
    end

    shared_context "for flowcell with a map of samples" do
      let(:lanes_description) do
        {}.tap do |lane|
          1.upto(8) do |lane_number|
            lane[lane_number-1] = [{
              :sample => new_sample(lane_number),
              :quantity => nil
            }]
          end
        end
      end
      subject do
        CreateFlowcell.new(:store => store, :user => user, :application => application)  do |action,session|
          action.lanes_description = lanes_description
        end
      end

      let (:flowcell_checker) do
        lambda do |flowcell|
          lanes_description.each do |lane_id, expected_aliquots|
            aliquots = flowcell[lane_id]
            aliquots.size.should == 1
            aliquots.first.sample.should == expected_aliquots.first[:sample]
          end
        end
      end
    end

    describe CreateFlowcell do
      context "valid calling context" do
        let!(:store) { Persistence::Store.new() }
        include_context "flowcell factory"
        include_context("for application",  "Test flowcell creation")

        context do
          include_context "for empty flowcell"
          it_behaves_like('creating a flowcell')
        end
        context do
          include_context "for flowcell with a map of samples"
          it_behaves_like('creating a flowcell')
        end
      end
    end

  end
end

