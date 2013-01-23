# Spec requirements
require 'actions/action_examples'
require 'persistence/sequel/store_shared'
require 'laboratory/tube_rack_shared'

# Model requirements
require 'lims/core/actions/tube_rack_move'
require 'lims/core/persistence/sequel/store'


module Lims::Core
  module Actions
    describe TubeRackMove do
      context "with a sequel store" do
        include_context "for application", "test tube rack move"
        include_context "prepare tables"
        include_context "tube_rack factory"

        let(:number_of_rows) { 8 }
        let(:number_of_columns) { 12 }
        let(:db) { ::Sequel.sqlite('') }
        let(:store) { Persistence::Sequel::Store.new(db) }
        before(:each) { prepare_table(db) }

        let(:source_id) {
          store.with_session do |session|
            rack = new_tube_rack_with_samples(1)
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

        # Tube already present in target tube rack
        context "invalid transfer" do
          let(:target_id) {
            store.with_session do |session|
              rack = new_tube_rack_with_samples(1) 
              session << rack
              lambda { session.tube_rack.id_for(rack) }
            end.call
          }

          subject do
            described_class.new(:store => store, :user => user, :application => application) do |a,s|
              a.source = s.tube_rack[source_id]
              a.target = s.tube_rack[target_id]
              a.move_map = {:A4 => :E9}
            end
          end

          it "fails" do
            expect { subject.call }.to raise_error(Laboratory::TubeRack::RackPositionNotEmpty)
          end
        end

        context "valid transfer" do
          let(:target_id) {
            store.with_session do |session|
              rack = new_empty_tube_rack 
              session << rack
              lambda { session.tube_rack.id_for(rack) }
            end.call
          }

          before(:each) { subject.call }
          subject do
            described_class.new(:store => store, :user => user, :application => application) do |a,s|
              a.source = s.tube_rack[source_id]
              a.target = s.tube_rack[target_id]
              a.move_map = {:A4 => :E10}
            end
          end

          it "saves the transfered rack" do
            store.with_session do |session|
              source = session.tube_rack[source_id]
              target = session.tube_rack[target_id]
              source[:A4].should be_nil
              target[:E10].should_not be_nil
              target[:E10].should be_a(Lims::Core::Laboratory::Tube)
            end
          end
        end
      end
    end
  end
end
