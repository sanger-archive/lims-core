# Spec requirements
require 'persistence/sequel/spec_helper'

require 'lims/core/persistence/label_filter'

module Lims::Core

  shared_examples_for "labels filtrable" do
    context "with a label" do
      let(:label_position) { "front barcode" }
      let(:label_value) { "01234" }
      let(:label) { Laboratory::SangerBarcode.new(:value => label_value) }
      let!(:labellable) { 
        store.with_session do |session|
          session << labellable = Laboratory::Labellable.new(:name => uuid, :type => "resource")
          labellable[label_position] = label
          labellable
        end
      }

      it "find the plate by label value", :focus => true  do
        filter = Persistence::LabelFilter.new(:label => {:value => label_value})
        search = Persistence::Search.new(:model => Laboratory::Plate, :filter => filter, :description => "lookup plate by label value")

        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0,1000).to_a
          all.size.should == 1
          all.first.should == session[uuid]
        end
      end
      it "find the plate by label position", :focus => true  do
        filter = Persistence::LabelFilter.new(:label => {:position => label_position})
        search = Persistence::Search.new(:model => Laboratory::Plate, :filter => filter, :description => "lookup plate by label value")

        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0,1000).to_a
          all.size.should == 1
          all.first.should == session[uuid]
        end
      end
    end
  end
end
