# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/store_shared'

# Model requirements
require 'lims/core/persistence/labellable'

module Lims::Core
  describe Laboratory::Labellable do
    include_context "sequel store"

    let(:name) { "test plate" }
    let(:type) { "plate" }
    let(:content) { { "front barcode" => "12345ABC" } }
    let(:parameters) { { :name => name, :type => type, :content => content } }
    let(:labellable) { described_class.new(parameters) }
    
    context "when created within a session" do
      it "should modify the labellable table" do
        expect do
          store.with_session { |session|
            session << labellable
          }
        end.to change { db[:labellables].count}.by(1)
          #db[:labellable_contents].count.by(1)
      end
    end

    it "should save it" do
      labellable_id = save(labellable).should_not be_nil
    end

    it "can be reloded" do  
      store.with_session do |session|
        session.labellable[labellable_id] = labellable
        session.labellable[labellable_id].name = labellable.name
        session.labellable[labellable_id].type = labellable.type
        session.labellable[labellable_id].content = labellable.content
      end
    end

    context "a labellable with content" do
      it "modifies the labellables table" do
        expect { save(labellable) }.to change { db[:labellables].count}.by(1)
      end
      it "modifies the contents table" do
        expect { save(labellable) }.to change { db[:contents].count}.by(1)
      end
    end
  end
end
