require 'persistence/sequel/spec_helper'
require 'persistence/sequel/store_shared'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/persistence/uuid_resource_persistor'

module Lims::Core
  module Persistence
    describe Sequel::UuidResource, :uuid_resource => true, :uuid => true, :persistence => true, :persistence => true, :sequel => true do
      include_context "sequel store"
      context "#saving" do
        before (:each) {
          db[:uuid_resources].delete
        }
        let(:model) { Laboratory::Tube }
        let(:key) { 1 }
        subject { UuidResource.new(:model_class => model, :key => key) }
        it "should modify the uuids table" do
          expect {
            store.with_session do |s|
            s << subject
            end
          }.to change { db[:uuid_resources].count }.by(1) 
        end
        context "reloaded" do
          let!(:uuid) { store.with_session do |session|
            session << subject
            subject.uuid
          end
          }

          let(:loaded) {
            store.with_session do |session|
            loaded = session.uuid_resource[:uuid => uuid]
            end
          }

          its(:key) { should == loaded.key }
          its(:model_class) { should == loaded.model_class }
        end

        context "bound to an object" do
          let(:sequence) { "AGA" }
          let(:model) { Laboratory::Oligo.new(:sequence =>sequence) }
          let(:uuid) {
            store.with_session do |session|
              session << model
              session.uuid_for!(model)
            end
          }

          context "when created" do
            it "modifies the uuid table " do
              expect { 
                uuid
              }.to change { db[:uuid_resources].count }.by(1)
            end
          end

          context "already saved" do
            before(:each) { uuid }
            it "reloads the same object" do
              store.with_session do |session|
                loaded = session[uuid]
                loaded.should == model
                loaded.sequence.should == sequence
              end
            end

            it "find the uuid for the object" do
              object_id = store.with_session do |session|
                session.id_for(session[uuid])
              end
              store.with_session do |session|
                loaded = session.oligo[object_id]
                session.uuid_for(loaded).should == uuid
              end
            end

            it "doesn't allow asking for an uuid of unmanaged object " do
              expect do
                store.with_session do |session|
                  session.uuid_for(model).should == uuid
                end
              end.to raise_error(RuntimeError)
            end
          end
        end
      end
    end
  end
end
