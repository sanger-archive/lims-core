# Spec requirements
require 'persistence/spec_helper'

# Model requirements
require 'lims-core/persistence/store'
require 'lims-core/persistence/session'


class Model
  attr_accessor :value
  def initialize(value)
    @value = value
  end

  def attributes
    {:value => @value }
  end
end

shared_examples "doesn't save 'clean' objects" do
  it "doesn't save read objects" do
    store.with_session do |session|
      loaded = session.model[1];
      loaded.should == a # test the test works !
      session.should_not_receive(:update_raw).with(a)
      session.should_receive(:save_raw).with(b)
      session << a << b
    end
  end
  it "save updated objects" do
    store.with_session do |session|
      loaded = session.model[1];
      loaded.value = "new value"
      session.should_receive(:update_raw).with(a)
      session.should_receive(:save_raw).with(b)
      session << a << b
    end
  end
end

module Lims::Core::Persistence
  module Sequel
    describe Session, :session => true, :persistence => true, :persistence => true do
      let(:store) { Store.new() }

      context "#transaction" do
        let(:a) { Model.new("A") }
        let(:b) { Model.new("B") }
        let(:c) { Model.new("C") }

        it "save the 2 if no problem" do
          store.with_session do |session|
            session.should_receive(:save).with(a)
            session.should_receive(:save).with(b)
            session << a << b
          end
        end

        context "#dirty attribute strategy" do
          # Mock session and persistor to load object
          let!(:persistor) {
            Session.stub(:model_for).with(:model) { Model }
            Session.stub(:persistor_class_for).with(Model) do 
              class ModelPersistor < Persistor
                @@objects ={}
                def self.register(key, value)
                  @@objects[key] =  value
                end
                def load_single_model(id, *args)
                  @@objects[id]
                end
              end
              ModelPersistor::register(1, a)
              ModelPersistor::register(2, b)
              ModelPersistor
            end
          }
          context "no strategy" do
            it "save read objects" do
              store.with_session do |session|
                loaded = session.model[1];
                loaded.should == a # test the test works !
                session.should_receive(:save).with(a)
                session.should_receive(:save).with(b)
                session << a << b
              end
            end
          end

          context "deep copy strategy" do
            before(:each) { store.dirty_attribute_strategy = Store::DIRTY_ATTRIBUTE_STRATEGY_DEEP_COPY }
            include_context "doesn't save 'clean' objects"
          end
          context "deep copy strategy" do
            before(:each) { store.dirty_attribute_strategy = Store::DIRTY_ATTRIBUTE_STRATEGY_SHA1 }
            include_context "doesn't save 'clean' objects"
          end
        end
      end
    end
  end
end
