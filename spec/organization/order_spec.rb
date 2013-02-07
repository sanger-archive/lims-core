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

shared_examples_for "unmodifiable states" do
  it_can_not_be_modified :creator
  it_can_not_be_modified :study
  it_can_not_be_modified :cost_code
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

        def self.it_can_assign(attribute)
          it "can assign #{attribute}" do
            value = mock(:attribute)
            subject.send("#{attribute}=", value)
            subject.send(attribute).should == value
          end
        end

        def self.it_can_not_be_modified(attribute)
          it "can't assign #{attribute}" do
            begin
              subject.should_not respond_to("#{attribute}=")
            rescue
              # if responds to, try to call the 
              expect {
                subject.send("#{attribute}=", mock(:attribute))
              }.to raise_error(NoMethodError)
            end
          end
        end
        #=== End of Macro ===

        let(:creator) { mock(:creator) }
        let(:pipeline) { "pipeline 1" }
        let(:parameters) { { :read_lenght => 26 } }
        let(:study) { mock(:study) }
        let(:cost_code) { "cost code" }
        let(:items) { {:source => mock(:source) } }
        let!(:creation_parameters) { { :creator => creator,
          :pipeline => pipeline,
          :parameters => parameters,
          :study => study, 
          :cost_code => cost_code }}

        # todo validation depends of the state
        context "to be valid" do
          it_needs_a :creator
          it_needs_a :pipeline
          it_needs_a :study
          it_needs_a :cost_code

          it "has private items" do
            subject.should_not respond_to(:items)
          end
        end

        it_has_a :creator
        it_has_a :pipeline
        it_has_a :parameters, Hash
        it_has_a :study
        it_has_a :status, String
        it_has_a :state, Hash
        it_has_a :cost_code, String

        it_can_not_be_modified :items

        context "valid" do
          subject { Order.new (creation_parameters) }
          its(:valid?) { should be_true }


          its(:status) { should == "draft" }

          context "#items" do
            let (:item) { mock(:item) }
            let(:role) { "role#1" }
            it "can have item added to it" do
              subject.add_item(role, item)
              subject[role].should include(item)
            end

            it "returns nil for unknown role" do
              subject[:unknown_role].should == nil
            end

            it "accepts items at initialization" do
              order = Order.new(creation_parameters.merge(:items => { role => [item] }))
              order[role].should include(item)
            end

            it "can have a source added" do
              subject.add_source(:source, source_uuid="source_id")
              debugger
              subject[:source].first.tap do |source|

                source.done?.should == true
                source.uuid.should == source_uuid
                source.iteration.should == 0
              end
            end

            it "can have a target added" do
              subject.add_target(:target)
              subject[:target].first.tap do |target|
                target.pending?.should == true
                target.iteration.should == 0
              end
            end

            context "with items" do
              let (:item2) { mock(:item2) }
              let (:item3) { mock(:item3) }
              let(:role2) { "role#2" }
              let(:items) { { role => [item], role2 => [item2, item3] } }
              subject { Order.new(creation_parameters.merge(items)) }
              it "can iterate over all the items" do
                roles = []
                items = []
                subject.should respond_to(:each) do |l_role, l_item|
                  l_item.should == case l_role
                                   when role then [item]
                                   when role2 then [item2, item3]
                                   else raise "Wrong Role"
                                   end
                end
              end
            end

          end
          context "draft" do
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

            it_can_assign :creator
            it_can_assign :study
            it_can_assign :cost_code

            it "can have a creator set" do
              creator = mock(:creator)
              (subject.creator=creator).should == creator
            end

            it "can have a study set" do
              study = mock(:study)
              (subject.study=study).should == study
            end

            context "-> pending" do
              before(:each) { subject.build }
              it_can_not_be_modified :creator
              it_can_not_be_modified :study
              it_can_not_be_modified :cost_code

              its(:status) { should == "pending" }

              it"can be cancelled" do
                subject.cancel.should == true
              end

              it "can be started" do
                subject.start.should == true
              end

              it "can't be finished" do
                subject.complete.should == false
              end

              context "-> in progress" do
                before(:each) { subject.start }
                its(:status) { should == "in_progress" }
                it_behaves_like "unmodifiable states"

                it"can be cancelled" do
                  subject.cancel.should == true
                end

                context "-> cancelled" do
                  before(:each) { subject.cancel }
                  it_behaves_like "terminal state"
                end


                it "can' be started" do
                  subject.start.should == false
                end

                it "can be failed" do
                  subject.fail.should == true
                  subject.status.should == "failed"
                end

                context "-> failed" do
                  before(:each) { subject.fail }
                  it_behaves_like "terminal state"
                end

                it "can be completed" do
                  subject.complete.should == true
                  subject.status.should == "completed"
                end
                context "-> completed" do
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

