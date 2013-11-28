require 'persistence/spec_helper'
require 'lims-core/persistence/persistor'

module Lims::Core::Persistence
  describe Persistor, :persistence => true do
    context "with a persistor module defined for the current persistor" do
      module PersistorModule
        module DefinedForAllPersistors
          def self.defined_for?(persistor)
            true
          end

          def method_defined_for_all_persistors
          end
        end
      end

      let(:session) { mock(:session) }

      it "extends the persistor with PersistorModule::Test on creation" do
        Persistor.any_instance.should_receive(:model)
        session.class.should_receive(:model_to_name)
        persistor = described_class.new(session)
        persistor.is_a?(PersistorModule::DefinedForAllPersistors).should == true
        persistor.should respond_to(:method_defined_for_all_persistors)
      end
    end


    context "with a persistor module not defined for the current persistor" do
      module PersistorModule
        module UndefinedForAllPersistors
          def self.defined_for?(persistor)
            false
          end

          def method_undefined_for_all_persistors
          end
        end
      end

      let(:session) { mock(:session) }

      it "does not extend the persistor with PersistorModule::Test on creation" do
        Persistor.any_instance.should_receive(:model)
        session.class.should_receive(:model_to_name)
        persistor = described_class.new(session)
        persistor.is_a?(PersistorModule::UndefinedForAllPersistors).should == false
        persistor.should_not respond_to(:method_undefined_for_all_persistors)
      end
    end
  end
end
