# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

#Model requirements
require 'lims-core/laboratory/spin_column/create_spin_column'
require 'laboratory/tube_shared'
require 'lims-core/persistence/store'

module Lims::Core
  module Laboratory
    describe SpinColumn::CreateSpinColumn, :spin_column => true, :laboratory => true, :persistence => true do
      context "with a valid store" do
        include_context "create object"
        let (:store) { Persistence::Store.new }
        include_context("for application", "Test create spin column")

        context "create an empty spin column" do
          subject do 
            SpinColumn::CreateSpinColumn.new(:store => store, :user => user, :application => application)  do |a,s|
            end
          end
          it_behaves_like "an action"
          it "create a spin column when called" do
            Persistence::Session.any_instance.should_receive(:save)
            result = subject.call
            result.should be_a(Hash)
            result[:spin_column].should be_a(Laboratory::SpinColumn)
            result[:uuid].should == uuid
          end
        end

        context "create a spin column with samples" do
          let(:sample) { new_sample(1) }
          subject do 
            SpinColumn::CreateSpinColumn.new(:store => store, :user => user, :application => application, :aliquots => [{:sample => sample }]) do |a,s|
            end
          end
          it_behaves_like "an action"
          it "create a spin column when called" do
            Persistence::Session.any_instance.should_receive(:save)
            result = subject.call
            result.should be_a(Hash)
            result[:spin_column].should be_a(Laboratory::SpinColumn)
            result[:uuid].should == uuid
            result[:spin_column].first.sample.should == sample
          end
        end
      end
    end
  end
end
