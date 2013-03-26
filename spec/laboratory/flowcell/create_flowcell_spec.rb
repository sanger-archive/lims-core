# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

require 'laboratory/flowcell_shared'

#Model requirement
require 'lims-core/laboratory/flowcell/create_flowcell'

module Lims::Core
  module Laboratory

    shared_context "for empty flowcell" do
      subject do
        Flowcell::CreateFlowcell.new(:store => store, :user => user, :application => application) do |action,session|
          action.ostruct_update(number_of_lanes_hash)
        end
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
        flowcell.number_of_lanes.should == number_of_lanes_hash[:number_of_lanes]
        flowcell_checker[flowcell]

        result[:uuid].should == uuid
      end
    end

    shared_context "for flowcell with a map of samples" do
      let(:lanes_description) do
        {}.tap do |lane|
          1.upto(number_of_lanes_hash[:number_of_lanes]) do |lane_number|
            lane[lane_number.to_s] = [{
              :sample => new_sample(lane_number),
              :quantity => nil
            }]
          end
        end
      end
      subject do
        Flowcell::CreateFlowcell.new(:store => store, :user => user, :application => application)  do |action,session|
          action.ostruct_update(number_of_lanes_hash)
          action.lanes_description = lanes_description
        end
      end

      let (:flowcell_checker) do
        lambda do |flowcell|
          lanes_description.each do |lane_name, expected_aliquots|
            aliquots = flowcell[lane_name.to_i-1]
            aliquots.size.should == 1
            aliquots.first.sample.should == expected_aliquots.first[:sample]
          end
        end
      end
    end

    shared_context "has number of lane" do |nb_of_lanes|
      let(:number_of_lanes_hash) { { :number_of_lanes => nb_of_lanes } }
    end
    
    shared_context "miseq flowcell" do
      include_context("has number of lane", 1)
    end
    
    shared_context "hiseq flowcell" do
      include_context("has number of lane", 8)
    end
    
    describe Flowcell::CreateFlowcell do
      context "valid calling context" do
        let!(:store) { Persistence::Store.new() }
        include_context "flowcell factory"
        include_context("for application",  "Test flowcell creation")
        
        # testing flowcell creation with miseq flowcell
        context do
          include_context "miseq flowcell"

          context do
            include_context "for empty flowcell"
            it_behaves_like('creating a flowcell')
          end
          context do
            include_context "for flowcell with a map of samples"
            it_behaves_like('creating a flowcell')
          end
        end
        
        # testing flowcell creation with hiseq flowcell
        context do
          include_context "hiseq flowcell"

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
end

