require 'lims-core/persistence/comparison_filter'

module Lims::Core
  shared_examples_for "comparison filter for plate" do
#    let(:model) { Lims::Core::Laboratory::Plate }
    let(:filter_model) { "plate" }
    let(:description) { "lookup plates with 8 rows" }
    let(:filter) { Persistence::ComparisonFilter.new(:criteria => criteria, :model => filter_model)}
    let(:search) { Persistence::Search.new(:model => model, :filter => filter, :description => description) }

    context "get resources by batch uuid criteria" do
      let(:criteria) { {:comparison => { "number_of_rows" => { "=" => 8} }} }
      it "finds plates" do
        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0, 1000).to_a
          all.size.should == 4
          all.each do |plate|
            plate.number_of_rows.should == 8
          end
          all.should include(session['22222222-1111-0000-0000-000000000000'])
          all.first.should be_a(model)
        end
      end
    end

    context "create plates with 2 rows and find it" do
      let(:number_of_rows) { 2 }
      let(:plate_2_rows) {
        store.with_session do |session|
          session << Laboratory::Plate.new(:number_of_rows => number_of_rows, :number_of_columns => number_of_columns)
        end
      }
      let(:criteria) { {:comparison => { "number_of_rows" => { "=" => 2} }} }

      it "finds plates" do
        store.with_session do |session|
          results = search.call(session)
          all = results.slice(0, 1000).to_a
          all.each do |plate|
            plate.number_of_rows.should == 2
          end
          all.size.should == 4
          all.first.should be_a(model)
        end
      end
    end
  end
end
