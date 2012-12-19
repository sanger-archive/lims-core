# Spec requirements
require 'actions/action_examples'

# Model requirements
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  module Actions
    shared_context "setup required attributes" do |name, type|
      let(:name) { name }
      let(:type) { type }
      let(:required_parameters) { { :name => name, :type => type } }
      let(:content) { { "front barcode" => SangerBarcode.new({:value =>"12345ABC" }) } }
    end
    
    shared_context "for empty Labellable" do
      subject do
        CreateLabellable.new(:store => store, :user => user, :application => application)  do |action, session|
          action.ostruct_update(required_parameters)
        end
      end
    end
    
    shared_context "for Laballable with barcode content" do
      
    end
    
    shared_examples_for "creating a Labellable" do
      it_behaves_like "an action"
    end
    
    describe CreateLabellable do
      context "with a valid store" do
        include_context "create object"
        it_behaves_like "an action"
        let (:store) { Persistence::Store.new }
        include_context("for application", "Test create laballable")
        
        it "creates a labellable object" do
          include_context("setup required attributes", "my test plate", "plate")
          
          context do
            include_context("for empty Labellable")
            it_behaves_like("creating a Labellable")
          end
          
          context do
            include_context("for Laballable with barcode content")
            it_behaves_like("creating a Labellable")
          end
        end
      end
    end
  end
end