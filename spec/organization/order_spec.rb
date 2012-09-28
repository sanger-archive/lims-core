require 'spec_helper'

require 'lims-core/organization/order'


module Lims
  module Core
    module Organization
      describe Order do
        def self.it_needs(attribute)
          context "is invalid" do
            subject {  Order.new(creation_parameters.except(attribute)) }
            it { subject.valid?.should == false }
            context "after validation" do
              before { subject.validate }
            its(:errors) { should include(attribute) }
            it "#{attribute} is required"  do
              subject.errors[attribute].to_s should == "required"
            end
            end
          end
        end
        let(:user) { mock(:user) }
        let(:pipeline) { "pipeline 1" }
        let(:parameters) { { :read_lenght => 26 } }
        let(:items) { {:source => mock(:source) } }
        let(:creation_parameters) { { :user => user,
          :pipeline => pipeline,
          :parameters => parameters,
          :items => items} }
        context "to be valid" do
          it_needs :user
          it_needs :pipeline
          it_needs :items
        end

        context "valid" do
          subject { Order.new (creation_parameters) }
          its(:valid?) { should be_true }
        end

        context "with items" do

        end

        context "#states" do
        end
      end
    end
  end
end
