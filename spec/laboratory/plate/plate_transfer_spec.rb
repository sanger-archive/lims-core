# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'
require 'laboratory/plate_and_gel_shared'

require 'persistence/sequel/store_shared'
#Model requirements
require 'lims-core/laboratory/plate/plate_transfer'
require 'lims-core/persistence/sequel/store'
require 'logger'

module Lims::Core
  module Laboratory
    describe Plate::PlateTransfer, :plate => true, :transfer => true, :laboratory => true, :persistence => true, :sequel => true do
      include_context "plate or gel factory"
        let(:user) { mock(:user) }
        let(:application) { "Test create plate" }
      def self.should_transfer 
        # @todo special test session class ?

        context "setup to transfert between valid plates" do
          let(:number_of_rows) { 8 }
          let(:number_of_columns) { 12 }
          let(:source) { new_plate_with_samples }
          let(:target) { new_empty_plate }
          subject do
            described_class.new(:store => store, :user => user, :application => application) do |a, s|
              a.target = target
              a.source = source
              a.transfer_map = { :C3 => :B1 }
            end 
          end
          it_behaves_like "an action"
          context "when called" do
            before { subject.call }
            it "should transfer samples" do
              target[:B1].should == source[:C3] 
            end
          end
        end
      end


      context "with a sequel store" do
        include_context "prepare tables"
        let(:db) { ::Sequel.sqlite('') }
        let(:store) { Persistence::Sequel::Store.new(db) }
        before (:each) { prepare_table(db) }

        context "with invalid paramters" do
          context "when called" do
          subject do
            described_class.new(:store => store, :user => user, :application => application)
          end
            before(:each)  {
              subject.call
            }

            its(:result) { should == nil }
            its(:errors) { should_not be_empty }
          end
        end
        # should_transfer

        context "with plates ids" do
          let(:number_of_rows) { 8 }
          let(:number_of_columns) { 12 }
          let(:source_id) do 
            store.with_session  do |s|
              s << plate=new_plate_with_samples
              lambda { s.plate.id_for(plate) } # called after save
            end.call
          end

          let(:target_id) do 
            store.with_session  do |s|
              s << plate=new_empty_plate
              lambda { s.id_for(plate) }
            end.call
          end

          context "when called without updating aliquot type" do
            subject do
              described_class.new(:store => store, :user => user, :application => application) do |a, s|
                a.source = s.plate[source_id]
                a.target = s.plate[target_id]
                a.transfer_map = { :C3 => :B1 }
              end 
            end
            before { subject.call }
            it "should save the transfered plates" do 
              store.with_session do |s|
                source, target = [source_id, target_id].map { |i| s.plate[i] }
                target[:B1].should == source[:C3]
              end
            end
          end

          context "when called updating aliquot type" do
            let(:aliquot_type) { "sample" }
            subject do
              described_class.new(:store => store, :user => user, :application => application) do |a, s|
                a.source = s.plate[source_id]
                a.target = s.plate[target_id]
                a.transfer_map = { :C3 => :B1 }
                a.aliquot_type = aliquot_type
              end 
            end
            before { subject.call }
            it "should save the transfered plates" do
              store.with_session do |s|
                source, target = [source_id, target_id].map { |i| s.plate[i] }
                target[:B1].should_not == source[:C3]
                target[:B1].each do |aliquot|
                  aliquot.type.should == aliquot_type
                end
                source[:C3].each do |aliquot|
                  aliquot.type.should be_nil
                end
              end
            end
          end
        end
      end
    end
  end
end
