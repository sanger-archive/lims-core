# Spec requirements
require 'persistence/sequel/spec_helper'
require 'persistence/sequel/store_shared'

# Model requirements
require 'lims-core/labels/labellable/labellable_persistor'
require 'lims-core/labels/sanger_barcode'

module Lims::Core
  describe Labels::Labellable, :labellable => true, :labels => true, :persistence => true, :sequel => true do
    include_context "sequel store"

    let(:name) { "test plate" }
    let(:type) { "plate" }
    let(:label_position) { "front barcode" }
    let(:label_value) { "12345ABC" }
    let(:content) { { label_position => Labels::SangerBarcode.new({:value => label_value}) } }
    let(:parameters) { { :name => name, :type => type, :content => content } }
    let(:labellable) { Labels::Labellable.new(parameters) }
    
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
        loaded_labellable.name.should == labellable.name
        loaded_labellable.type.should == labellable.type
        loaded_labellable.content.should == labellable.content
        loaded_labellable["front barcode"].should be_a(Labels::SangerBarcode)
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

    context "lookup", :focus => true do
      before do
        store.with_session do |session|
          session << labellable
          session.uuid_for!(labellable)
        end
      end

      it "finds the labellable by label value" do
        filter = Persistence::LabelFilter.new(:label => {:value => label_value})
        search = Persistence::Search.new(:model => Labels::Labellable, :filter => filter, :description => "search")
        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0, 1000).to_a
          all.size.should == 1
          all.first.should == labellable
        end
      end

      it "finds the labellable by label position" do
        filter = Persistence::LabelFilter.new(:label => {:position => label_position})
        search = Persistence::Search.new(:model => Labels::Labellable, :filter => filter, :description => "search")
        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0, 1000).to_a
          all.size.should == 1
          all.first.should == labellable
        end
      end
    end
  end
end
