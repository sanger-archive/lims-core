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
        key ||= @@objects.size + 1
        @@objects[key] =  value
        key
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
                Model::ModelPersistor.any_instance.should_not_receive(:bulk_update) do |states|
                  states.size == 1
                  states.first.resource.should == a
                  1
                end
                Model::ModelPersistor.any_instance.should_receive(:bulk_insert) do |states|
                  states.map(&:resource).should include b
                  states.map(&:resource).should_not include a
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

        context "#nested" do
          before(:each) { 
            Model::ModelPersistor.any_instance.stub(:insert) do |state|
              # We stub insert to register object so they can be reloaded.
              # However, the registration is a class method therefore common
              # to all Persistor. That should work because an new id is given
              # even if the object has already been registered from another Persistor.
              state.inserted(Model::ModelPersistor::register(nil, state.resource))
            end
          }
          it "share object states with parent" do
            store.with_session do |session|
              session << a

              session.with_subsession do |sub_session|
                session.state_for(a).should equal(sub_session.state_for(a))
              end
            end
          end

          it "can access object from children session " do
            store.with_session do |session|
              id = session.with_subsession do |sub_session|
                sub_session << a
                lambda { sub_session.id_for(a) }
              end.call
              session.model[id].should equal(a)

              store.with_session do |sub_session|
              end
            end
          end

          it "saves object in corresponding transaction"  do
            last_session = store.with_session do |session|
              session << a
              session.with_subsession do |sub_session|
                sub_session <<  b
              end

              session.state_for(a).new?.should == true # not saved yet
              session.state_for(b).new?.should == false # saved by now

              session
            end
            last_session.state_for(a).new?.should == false # saved by now
          end
        end
      end
    end
  end
end
