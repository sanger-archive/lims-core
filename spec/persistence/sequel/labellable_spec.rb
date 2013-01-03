# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/store_shared'

# Model requirements
require 'lims/core/persistence/labellable'
require 'lims/core/laboratory/sanger_barcode'

module Lims::Core
  describe Laboratory::Labellable do
    include_context "sequel store"

    let(:name) { "test plate" }
    let(:type) { "plate" }
    let(:content) { { "front barcode" => Laboratory::SangerBarcode.new({ :value =>"12345ABC" }) } }
    let(:parameters) { { :name => name, :type => type, :content => content } }
    let(:labellable) { Laboratory::Labellable.new(parameters) }
    
    context "when created within a session" do
      it "should modify the labellable table" do
        expect do
          store.with_session { |session| session << labellable }
        end.to change { db[:labellables].count}.by(1)
      end
    end

    it "should save it" do
      labellable_id = save(labellable).should be_true
    end

    it "can be reloaded" do
      labellable_id = save(labellable)
      store.with_session do |session|
        loaded_labellable = session.labellable[labellable_id]
        loaded_labellable.should == labellable
        loaded_labellable.name == labellable.name
        loaded_labellable.type == labellable.type
        loaded_labellable.content == labellable.content
        loaded_labellable["front barcode"].should be_a(Laboratory::SangerBarcode)
      end
    end

    context "a labellable with content" do
      it "modifies the labellables table" do
        expect { save(labellable) }.to change { db[:labellables].count}.by(1)
      end
      it "modifies the labels table" do
        expect { save(labellable) }.to change { db[:labels].count}.by(1)
      end
    end
  end
end
