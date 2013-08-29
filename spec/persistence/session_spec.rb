# Spec requirements
require 'persistence/spec_helper'

# Model requirements
require 'lims-core/persistence/store'
require 'lims-core/persistence/session'


module SessionSpec
class Model
  include Lims::Core::Resource
  attribute :value, String

  def initialize(args)
    case args
    when String then @value = args
    else
      super(args)
    end
  end
  def attributesX
    {:nesting => {:value => @value} }
  end

  class ModelPersistor < Lims::Core::Persistence::Persistor
    Model = SessionSpec::Model
    @@objects ={}
    def self.register(key, value)
      @@objects[key] =  value
    end

    def bulk_load(states, *params, &block)
      states.map { |state| block.call(@@objects[state.id].attributes.merge(id:state.id)) }
    end

    def self.clear()
      @@objects ={}
    end
  end
end


shared_examples "doesn't save 'clean' objects" do
  it "doesn't save read objects" do
    store.with_session do |session|
      loaded = session.model[1]
      loaded.should == a # test the test works !
        Model::ModelPersistor.any_instance.should_not_receive(:insert) do |state|
          state.resource.should == a
        end
        Model::ModelPersistor.any_instance.should_receive(:insert) do |state|
          state.resource.should == b
        end
      session << loaded << b
    end
  end
  it "updates 'dirty' objects" do
    store.with_session do |session|
      loaded = session.model[1]
      loaded.value = "new value"
        Model::ModelPersistor.any_instance.should_not_receive(:insert) do |state|
          state.resource.should == a
        end
              Model::ModelPersistor.any_instance.should_receive(:bulk_update) do |states|
                states.size == 1
                states.first.resource.should == loaded
                1
              end
        Model::ModelPersistor.any_instance.should_receive(:insert) do |state|
          state.resource.should == b
          2
        end
      session << loaded << b
    end
  end
end

module Lims::Core::Persistence
  describe Session, :session => true, :persistence => true, :persistence => true do
    let(:store) { Store.new() }

    context "#transaction" do
      let(:a) { Model.new("A") }
      let(:b) { Model.new("B") }
      let(:c) { Model.new("C") }

      it "save the 2 if no problem" do
        Model::ModelPersistor.any_instance.should_receive(:insert) do |state|
          state.resource.should == a
        end
        Model::ModelPersistor.any_instance.should_receive(:insert) do |state|
          state.resource.should == b
        end
        store.with_session do |session|
          session << a << b
        end
      end

      context "#dirty attribute strategy" do
        # Mock session and persistor to load object
        let!(:persistor_class) {
          Session.stub(:model_for) { Model }
          Session.stub(:persistor_class_for).with(Model) do 
              Model::ModelPersistor::clear()
              Model::ModelPersistor::register(1, a)
              Model::ModelPersistor::register(2, b)
              Model::ModelPersistor
          end
        }
        context "no strategy" do
          it "save read objects" do
            store.with_session do |session|
              session.dirty_attribute_strategy = nil
              loaded = session.model[1];
              loaded.should == a # test the test works !
              Model::ModelPersistor.any_instance.should_not_receive(:insert) do |state|
                state.resource.should == a
                1 
              end
              Model::ModelPersistor.any_instance.should_not_receive(:bulk_update) do |states|
                states.size == 1
                states.first.resource.should == a
                1
              end
              Model::ModelPersistor.any_instance.should_receive(:insert) do |state|
                state.resource.should == b
                2 
              end
              session << loaded  << b
            end
          end
        end

        context "deep copy strategy" do
          before(:each) { store.dirty_attribute_strategy = Store::DIRTY_ATTRIBUTE_STRATEGY_DEEP_COPY }
          include_context "doesn't save 'clean' objects"
        end
        context "sha1 strategy" do
          before(:each) { store.dirty_attribute_strategy = Store::DIRTY_ATTRIBUTE_STRATEGY_SHA1 }
          include_context "doesn't save 'clean' objects"
        end
        context "md5 strategy", :focus => true do
          before(:each) { store.dirty_attribute_strategy = Store::DIRTY_ATTRIBUTE_STRATEGY_MD5 }
          include_context "doesn't save 'clean' objects"
        end
      end
    end
  end
end
end
