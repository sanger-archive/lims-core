# Spec requirements
require 'actions/action_examples'
require 'persistence/sequel/store_shared'

# Model requirements
require 'lims/core/actions/tube_rack_transfer'
require 'lims/core/persistence/sequel/store'


module Lims::Core
  module Actions

    shared_context "tube rack factory" do
      let(:number_of_rows) { 8 }
      let(:number_of_columns) { 12 }
 
      def new_rack_with_tubes(tubes_location = [])
        Laboratory::TubeRack.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns).tap do |rack|
          tubes_location.each do |location|
            tube = Laboratory::Tube.new
            tube << new_aliquot(location)
            rack[location] = tube
          end
        end
      end

      def new_rack_with_empty_tubes(tubes_location = [])
        Laboratory::TubeRack.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns).tap do |rack|
          tubes_location.each do |location|
            rack[location] = Laboratory::Tube.new
          end
        end
      end

      def new_aliquot(str)
        Laboratory::Aliquot.new(:sample => new_sample(str))
      end

      def new_sample(str)
        Laboratory::Sample.new("Sample_#{str}")
      end
    end


    describe TubeRackTransfer do
      context "with a sequel store" do
        include_context "for application", "test tube rack transfer"
        include_context "prepare tables"
        include_context "tube rack factory"
        
        let(:db) { ::Sequel.sqlite('') }
        let(:store) { Persistence::Sequel::Store.new(db) }
        before(:each) { prepare_table(db) }
        
        let(:source_id) {
          store.with_session do |session|
            rack = new_rack_with_tubes(["A4"]) 
            session << rack
            lambda { session.tube_rack.id_for(rack) }
          end.call
        }

        let(:target_id) {
          store.with_session do |session|
            rack = new_rack_with_empty_tubes(["E9"])
            session << rack
            lambda { session.tube_rack.id_for(rack) }
          end.call
        }


        context "invalid action parameters" do
          subject { described_class.new(:store => store, :user => user, :application => application) }
          before(:each) { subject.call }
          its(:result) { should be_nil }
          its(:errors) { should_not be_empty }
        end


        # No tube in target rack B1
        context "invalid transfer" do 
          subject do
            described_class.new(:store => store, :user => user, :application => application) do |a,s|
              a.source = s.tube_rack[source_id]
              a.target = s.tube_rack[target_id]
              a.transfer_map = {:A4 => :B1}
            end
          end

          it "fails" do
            expect { subject.call }.to raise_error(TubeRackTransfer::NoTubeInTargetLocation)
          end
        end


        context "valid transfer" do
          before(:each) { subject.call }
          subject do
            described_class.new(:store => store, :user => user, :application => application) do |a,s|
              a.source = s.tube_rack[source_id]
              a.target = s.tube_rack[target_id]
              a.transfer_map = {:A4 => :E9}
            end
          end

          it "saves the transfered rack" do
            store.with_session do |session|
              source = session.tube_rack[source_id]
              target = session.tube_rack[target_id]
              target[:E9].should == source[:A4]
            end
          end
        end
      end
    end
  end
end
