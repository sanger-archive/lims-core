# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'spec_helper'

require 'lims-core/organization/order/item'

module Lims
  module Core
    module Organization
      describe Order::Item do
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
            subject {  described_class.new(creation_parameters.except(attribute)) }
            it { subject.valid?.should == false }
            context "after validation" do
              before { subject.validate }
              it "#{attribute} is required" do
                subject.errors[attribute].should_not be_empty
              end
            end
          end
        end

        def self.it_can_not_be_modified(attribute)
          it "can't assign #{attribute}" do
            begin
              subject.should_not respond_to("#{attribute}=")
            rescue
              # if responds to, try to call the 
              expect {
                subject.send("#{attribute}=", nil)
              }.to raise_error(NoMethodError)
            end
          end
        end
        #=== End of Macro ===
	

				it_has_a :status
				it_has_a :iteration
				it_has_a :uuid

				it "is initially in a pending status" do
					subject.status.should == "pending"
				end

				# state machine
				context "pending" do
					its(:iteration) { should == 0 }
					it "can be started" do
						subject.start.should == true
					end

					context "source" do
						before(:each) { subject.complete }
						its(:status) { should == "done" }
						its(:done?) { should be_true }
						its(:iteration) { should == 0 }

						it_can_not_be_modified :iteration
						it_can_not_be_modified :uuid

						it "can't no be reset" do
							subject.reset.should == false
						end
					end

					context "in progress" do
						before(:each) { subject.start }
						its(:status) { should == "in_progress" }
						its(:iteration) { should == 1 }

						it "can fail" do
							subject.fail.should == true
						end

						it "can succeed" do
							subject.complete.should == true
						end

						context "failed" do
							before(:each) { subject.fail }
							it "can be reset to pending" do
								subject.reset.should == true
							end

							it "can be restarted" do
								subject.start.should == true
							end
							it "increments iteration when started" do
								subject.reset
								subject.start
								subject.iteration.should == 2
							end

							it "increments when restarted" do
								subject.start
								subject.iteration.should == 2
							end
						end
					end
				end
      end
    end
  end
end

