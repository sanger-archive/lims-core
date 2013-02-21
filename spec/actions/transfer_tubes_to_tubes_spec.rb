#Spec requirements
require 'persistence/sequel/store_shared'

require 'persistence/sequel/spec_helper'
require 'laboratory/tube_shared'
require 'laboratory/spin_column_shared'

# Model requirements
require 'lims/core/actions/transfer_tubes_to_tubes'

shared_examples_for "transfer tube to spin column" do
  it "transfers a tube like(s)'s content to tube-like(s) as expected" do
    subject.call
    store.with_session do |session|
      tube1, tube2 = [tube1_id, tube2_id].map { |id| session.tube[id] }
      spin_column1, spin_column2 = [spin_column1_id, spin_column2_id].map { |id| session.spin_column[id] }

      spin_column1.size.should == tube1.size
      spin_column1.each do |aliquot|
        unless aliquot.type == Lims::Core::Laboratory::Aliquot::Solvent
          aliquot.type.should == type1
        end
        aliquot.quantity.should == finalQuantity1
      end

      spin_column2.size.should == tube2.size
      spin_column2.each do |aliquot|
        unless aliquot.type == Lims::Core::Laboratory::Aliquot::Solvent
          aliquot.type.should == type2
        end
        aliquot.quantity.should == finalQuantity2
      end
    end
  end
end

shared_examples_for "transfer spin column to tube" do
  it "transfers a tube like(s)'s content to tube-like(s) as expected" do
    subject.call
    store.with_session do |session|
      tube1, tube2 = [tube1_id, tube2_id].map { |id| session.tube[id] }
      spin_column1, spin_column2 = [spin_column1_id, spin_column2_id].map { |id| session.spin_column[id] }

      tube1.size.should == spin_column1.size
      tube1.each do |aliquot|
        unless aliquot.type == Lims::Core::Laboratory::Aliquot::Solvent
          aliquot.type.should == type1
        end
        aliquot.quantity.should == finalQuantity1
      end
      tube2.size.should == spin_column2.size
      tube2.each do |aliquot|
        unless aliquot.type == Lims::Core::Laboratory::Aliquot::Solvent
          aliquot.type.should == type2
        end
        aliquot.quantity.should == finalQuantity2
      end
    end
  end
end

shared_examples_for "transfer a tube content to a spin column and a tube" do
  it "transfers a tube like(s)'s content to tube-like(s) as expected" do
    subject.call
    store.with_session do |session|
      tube1, tube2 = [tube1_id, tube2_id].map { |id| session.tube[id] }
      spin_column1 = session.spin_column[spin_column1_id]

      spin_column1.size.should == tube1.size
      spin_column1.each do |aliquot|
        unless aliquot.type == Lims::Core::Laboratory::Aliquot::Solvent
          aliquot.type.should == type1
        end
        aliquot.quantity.should == finalQuantity1
      end
      tube2.size.should == tube1.size
      tube2.each do |aliquot|
        unless aliquot.type == Lims::Core::Laboratory::Aliquot::Solvent
          aliquot.type.should == type2
        end
        aliquot.quantity.should == finalQuantity2
      end
    end
  end
end

module Lims::Core
  module Actions
    describe TransferTubesToTubes do
      include_context "spin column factory"
      include_context "tube factory"

      context "with a sequel store" do
        include_context "sequel store"

        context "and everything already in the database" do
          let(:user) { mock(:user) }
          let(:application) { "test transfer tube-like(s) to tube-like(s)" }

          context "with valid parameters" do
            let(:type1) { "NA" }
            let(:type2) { "DNA" }
            context "transfer tubes to spin columns with amount", :focus => true do
              let(:quantity1) { 100 }
              let(:quantity2) { 100 }
              let(:spin_column1_id) { save(new_empty_spin_column) }
              let(:spin_column2_id) { save(new_empty_spin_column) }
              let(:tube1_id) { save(new_tube_with_samples(10, quantity1, quantity1)) }
              let(:tube2_id) { save(new_tube_with_samples(10, quantity2, quantity2).tap do |tube|
                    tube.each { |a| a.type = type2 unless a.type }
                  end
                ) }
              let(:amount1) { 80 }
              let(:amount2) { 40 }
              let!(:finalQuantity1) { 80 }
              let!(:finalQuantity2) { 40 }

              subject { described_class.new(:store => store, 
                                            :user => user, 
                                            :application => application) do |action, session|
                tube1, tube2 = [tube1_id, tube2_id].map { |id| session.tube[id] }
                spin_column1, spin_column2 = [spin_column1_id, spin_column2_id].map { |id| session.spin_column[id] }

                action.transfers = [ { "source" => tube1,
                                        "target" => spin_column1,
                                        "amount" => amount1,
                                        "aliquot_type" => type1},
                                     { "source" => tube2,
                                       "target" => spin_column2,
                                       "amount" => amount2
                                       # We don't change the type of this one
                                       # so, it should be the same as the initial tube
                                     }
                                   ]
              end
              }

              it_behaves_like "transfer tube to spin column"
            end

            context "transfer spin columns to tubes with fraction" do
              let(:quantity1) { 100 }
              let(:quantity2) { 100 }
              let(:number_of_samples) { 10 }
              let(:spin_column1_id) { save(new_spin_column_with_samples(number_of_samples, quantity1, quantity1)) }
              let(:spin_column2_id) { save(new_spin_column_with_samples(number_of_samples, quantity2, quantity2)) }
              let(:tube1_id) { save(new_empty_tube) }
              let(:tube2_id) { save(new_empty_tube) }
              let(:fraction1) { 0.6 }
              let(:fraction2) { 0.4 }
              let!(:finalQuantity1) { 60 }
              let!(:finalQuantity2) { 40 }

              subject { described_class.new(:store => store, 
                                            :user => user, 
                                            :application => application) do |action, session|
                tube1, tube2 = [tube1_id, tube2_id].map { |id| session.tube[id] }
                spin_column1, spin_column2 = [spin_column1_id, spin_column2_id].map { |id| session.spin_column[id] }
                
                action.transfers = [ { "source" => spin_column1,
                                        "target" => tube1,
                                        "fraction" => fraction1,
                                        "aliquot_type" => type1},
                                     { "source" => spin_column2,
                                       "target" => tube2,
                                       "fraction" => fraction2,
                                       "aliquot_type" => type2}
                                   ]
              end
              }

              it_behaves_like "transfer spin column to tube"
            end

            context "transfer from tubes to spin column and tube with fraction" do
              let(:quantity1) { 100 }
              let(:number_of_samples) { 10 }
              let(:tube1_id) { save(new_tube_with_samples(number_of_samples, quantity1)) }
              let(:tube2_id) { save(new_empty_tube) }
              let(:spin_column1_id) { save(new_empty_spin_column) }
              let(:fraction1) { 0.6 }
              let(:fraction2) { 1 }
              let!(:finalQuantity1) { 60 }
              let!(:finalQuantity2) { 40 }
              let(:type1) { "DNA" }
              let(:type2) { "NA" }

              subject { described_class.new(:store => store, 
                                            :user => user, 
                                            :application => application) do |action, session|
                tube1, tube2 = [tube1_id, tube2_id].map { |id| session.tube[id] }
                spin_column1 = session.spin_column[spin_column1_id]

                action.transfers = [ { "source" => tube1,
                                        "target" => spin_column1,
                                        "fraction" => fraction1,
                                        "aliquot_type" => type1},
                                     { "source" => tube1,
                                       "target" => tube2,
                                       "fraction" => fraction2,
                                       "aliquot_type" => type2
                                     }
                                   ]
              end
              }

              it_behaves_like "transfer a tube content to a spin column and a tube"
            end
          end
        end
      end
    end
  end
end
