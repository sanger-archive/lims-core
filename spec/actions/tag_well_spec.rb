# Spec requirements
require 'actions/spec_helper'
require 'actions/action_examples'

require 'persistence/sequel/spec_helper'
require 'laboratory/plate_shared'
require 'persistence/sequel/store_shared'

#Model requirements
require 'lims/core/actions/tag_wells'

require 'lims/core/persistence/sequel/store'

require 'logger'
DB = Sequel.sqlite '', :logger => Logger.new($stdout)
PS=Lims::Core::Persistence::Sequel

module Lims::Core
  module Actions
    describe TagWells do
      include_context "plate factory"
      let(:row_number) {8}
      let(:column_number) {12}
      context "with a sequel store" do
        include_context "prepare tables"
        let(:db) { ::Sequel.sqlite('') }
        let(:store) { PS::Store.new(db) }
        before (:each) { prepare_table(db) }

        context "and everything already in the database" do
          let(:plate_id) { save(new_plate_with_samples(1)) }
          let(:oligo_1_id) { save(Laboratory::Oligo.new("AAA")) }
          let(:oligo_2_id) { save(Laboratory::Oligo.new("TAG")) }
          let(:well_to_tag_id_map) { { :C1 => oligo_1_id, :F7 => :oligo_2_id } }

          let(:user) { mock(:user) }
          let(:application) { "Test assign tag to well" }
          subject { described_class.new(:store => store, :user => user, :application => application) do |a,s|
            a.plate = s.plate[plate_id]
            a.well_to_tag_map = well_to_tag_id_map.map { |w,t_id| [w, s.oligo[t_id]] }
          end
          }

          it "tags the well as expected" do
            subject.call
            store.with_session do |session|
              plate = session.plate[plate_id]
              oligo_1 = session.oligo[oligo_1]
              oligo_2 = session.oligo[oligo_2]

              plate.each_with_index do  |well, name|
                well.each do |aliquot|
                  aliquot.tag.should == case name
                                        when "C1" then oligo_1
                                        when "F7" then oligo_2
                                        else nil
                                        end
                end
              end
            end
          end
        end

        context "with an empty database" do
      let(:row_number) {3}
      let(:column_number) {1}
          let(:user) { mock(:user) }
          let(:application) { "Test assign tag to well" }
          subject { described_class.new(:store => store, :user => user, :application => application) do |a,s|
            s << a.plate=new_plate_with_samples(1)
            a.well_to_tag_map = { "C1" => Laboratory::Oligo.new("TAG") }
          end
          }

          it "should save everything" do
            plate_id = subject.call { |a, s| s.id_for(a.plate) }
            store.with_session do |session|
              plate = session.plate[plate_id]
              plate[:C1].first.tag.should == "TAG"
            end
          end
        end
      end
    end
  end
end
