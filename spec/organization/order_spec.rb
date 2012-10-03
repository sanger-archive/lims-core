require 'spec_helper'

require 'lims-core/organization/order'


share_examples_for "terminal state" do
  it "can' be started" do
    subject.start.should == false
  end
  it "can' be completed" do
    subject.complete.should == false
  end
  it "can' be failed" do
    subject.fail.should == false
  end            
  it "can' be built" do
    subject.build.should == false
  end

  it "can't be completed" do
    subject.complete.should == false
  end
end

module Lims
  module Core
    module Organization
      describe Order do
        #== Macro ====
        def self.it_has_a(attribute, type=nil)
          it "responds to #{attribute}" do
            subject.should respond_to(attribute)
          end

          if type
            it "'s #{attribute} is a #{type}" do
              subject.send(attribute).andtap { |v| v.should be_a(type) }
            end
          end
        end

        def self.it_needs_a(attribute)
          context "is invalid" do
            subject {  Order.new(creation_parameters.except(attribute)) }
            it { subject.valid?.should == false }
            context "after validation" do
              before { subject.validate }
              it "#{attribute} is required" do
                subject.errors[attribute].should_not be_empty
              end
            end
          end
        end

        def self.it_can_not_change(attribute)
          it "can't assign #{attribute}" do
            subject.should_not respond_to("#{attribute}=")
          end
        end
        #=== End of Macro ===

        let(:user) { mock(:user) }
        let(:pipeline) { "pipeline 1" }
        let(:parameters) { { :read_lenght => 26 } }
        let(:items) { {:source => mock(:source) } }
        let!(:creation_parameters) { { :user => user,
          :pipeline => pipeline,
          :parameters => parameters }}

        # todo validation depends of the state
        context "to be valid" do
          it_needs_a :user
          it_needs_a :pipeline
          it_needs_a :study
          it_needs_a :cost_code
        end

        it_has_a :creator
        it_has_a :pipeline
        it_has_a :parameters, Hash
        it_has_a :study
        it_has_a :status, String
        it_has_a :state, Hash
        it_has_a :cost_code, String

        it_can_not_change :creator
        it_can_not_change :study
        it_can_not_change :items
        it_can_not_change :status

        context "valid" do
          subject { Order.new (creation_parameters) }
          its(:valid?) { should be_true }


          its(:status_name) { should == :draft }

          context "#items" do
            let (:item) { mock(:item) }
            let(:role) { "role#1" }
            it "can have item added to it" do
              subject[role] = item
              subject[role].should == item
            end

            it "returns nil for unknown role" do
              subject[:unknown_role].should == nil
            end

            it "accepts items at initialization" do
              order = Order.new(creation_parameters.merge(:item => { role => item }))
              order[role].should == item
            end

            context "with items" do
              let (:item2) { mock(:item2) }
              let(:role2) { "role#2" }
              let(:items) { { role => item, role2 => item2 } }
              subject { Order.new(creation_parameters.merge(items)) }
              it "can iterate over all the items" do
                roles = []
                items = []
                subject.should respond_to(:each) do |l_role, l_item|
                  l_item.should == case l_role
                                   when role then item
                                   when role2 then item2
                                   else raise "Wrong Role"
                                   end
                end
              end
            end

          end
          context "building" do
            its(:status) { should == "draft" }
            it "can be built" do
              subject.build.should == true
            end

            it"can be cancelled" do
              subject.cancel.should == true
            end

            it "can' be started" do
              subject.start.should == false
            end
            it"can be cancelled" do
              subject.cancel.should == true
            end
            it "can't be finished" do
              subject.complete.should == false
            end
            context "pending" do

              its(:status_name) { should == "pending" }

              it"can be cancelled" do
                subject.cancel.should == true
              end

              it "can be started" do
                subject.start.should == true
              end

              it "can't be finished" do
                subject.complete.should == false
              end

              context "in progress" do
                before(:each) { subject.start }
                its(:status_name) { should == "in_progress" }

                it"can be cancelled" do
                  subject.cancel.should == true
                end

                context "cancelled" do
                  before(:each) { subject.cancel }
                  it_behaves_like "terminal state"
                end


                it "can' be started" do
                  subject.start.should == false
                end

                it "can be failed" do
                  subject.fail.should == true
                  subject.state.should == "in_progress"
                end
                context "failed" do
                  before(:each) { subject.fail }
                  it_behaves_like "terminal state"
                end

                it "can be completed" do
                  subject.complete.should == true
                  subject.state.should == "completed"
                end
                context "completed" do
                  before(:each) { subject.complete }
                  it_behaves_like "terminal state"
                end
              end
            end
          end
        end
      end
    end
  end
end

