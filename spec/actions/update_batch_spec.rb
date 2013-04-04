# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

# Model requirements
require 'lims/core/actions/update_batch'
require 'lims/core/organization/batch'

module Lims::Core
  module Actions
    describe UpdateBatch do
      context "valid calling context" do
        include_context "for application", "test update batch"
        include_context "create object"

        let(:store) { Persistence::Store.new }
        let(:process) { "process" }
        let(:kit) { "kit" }
        let(:action) {
          described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.batch = Organization::Batch.new
            a.process = process
            a.kit = kit
          end
        }
        let(:result) { action.call }
        let(:updated_batch) { result[:batch] }
        subject { action }

        it_behaves_like "an action"

        it "updates the batch" do
          result.should be_a Hash
          updated_batch.should be_a Organization::Batch
        end

        it "changes the process" do
          updated_batch.process.should == process
        end

        it "changes the kit" do
          updated_batch.kit.should == kit
        end
      end
    end
  end
end
