# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

#Model requirements
require 'lims-core/organization/batch/create_batch'
require 'lims-core/persistence/store'

module Lims::Core
  module Organization
    describe Batch::CreateBatch, :batch => true, :organization => true, :sequel => true do
      context "with a valid store" do
        include_context "create object"
        let (:store) { Persistence::Store.new }
        let(:user) { mock(:user) }
        let(:application) { "Test create batch" }
        let(:process) { mock(:process) }

        context "create a batch" do
          subject do
            described_class.new(:store => store, :user => user, :application => application)  do |a,s|
              a.process = process
            end
          end 

          it_behaves_like "an action"

          it "create a batch when called" do
            Persistence::Session.any_instance.should_receive(:save)
            result = subject.call
            result.should be_a(Hash)
            result[:batch].should be_a(Organization::Batch)
            result[:batch][:process].should == process
            result[:uuid].should == uuid
          end
        end
      end
    end
  end
end
