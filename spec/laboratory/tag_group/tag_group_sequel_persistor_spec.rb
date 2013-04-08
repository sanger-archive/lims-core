# Spec requirements
require 'persistence/sequel/spec_helper'

require 'persistence/sequel/store_shared'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/laboratory/tag_group/all'

module Lims::Core

  describe Laboratory::TagGroup::TagGroupSequelPersistor, :tag_group => true, :tag => true, :laboratory => true, :persistence => true, :sequel => true do
    include_context "prepare tables"
    let(:db) { ::Sequel.sqlite('') }
    let(:store) { Persistence::Sequel::Store.new(db) }
    before (:each) { prepare_table(db) }

    let (:old_oligo) { Laboratory::Oligo.new ("AAA") }
    let (:new_oligo) { Laboratory::Oligo.new ("TTT") }
    let (:group)  { Laboratory::TagGroup.new("my group", old_oligo) }
    let (:empty_group)  { Laboratory::TagGroup.new("empty group") }

    context "created and added to session" do
      it "modifies the tag_groups table" do
        expect do
          store.with_session { |s| s << group }
        end.to change { db[:tag_groups].count }.by(1)
      end

      it "modifies the tag_group_associations table" do
        expect do
          store.with_session { |s| s << group }
        end.to change { db[:tag_group_associations].count }.by(1)
      end

      context "existing in the database" do
        # The '!' is important, the session needs to be created before running
        # the example.
        let!(:group_id) {
          store.with_session do |session|
          session << group
          lambda { session.id_for(group) }
          end.call 
        }

        it "should be reloadable" do
          store.with_session do |session|
            loaded_group = session.tag_group[group_id]
            loaded_group.should == group
            loaded_group.name.should == "my group"
            loaded_group[0].should == Laboratory::Oligo.new(old_oligo.sequence)
          end
        end

        it "should be updated when modified" do
          store.with_session do |session|
            session.tag_group[group_id][0] = new_oligo
          end

          store.with_session do |session|
            session.tag_group[group_id][0].should == new_oligo
          end
        end

        context "adding a new tag" do
          def add_a_new_tag 
            store.with_session do |session|
              session.tag_group[group_id] << new_oligo
            end
          end
          it "should change the tag_group_association table" do
            expect { add_a_new_tag }.to change { db[:tag_group_associations].count }.by(1)
          end
          it "should change the oligos table" do
            expect { add_a_new_tag }.to change { db[:oligos].count }.by(1)
          end

          it "should save the new oligo" do
            add_a_new_tag
            store.with_session do |session|
              session.tag_group[group_id].content.should == [old_oligo, new_oligo]
              session.tag_group[group_id].should == Laboratory::TagGroup.new(group.name, old_oligo, new_oligo)
            end
          end


          context "already saved" do
            let!(:new_oligo_id)  { save(new_oligo) }
            it "shouldn't change the oligos table" do
              expect { store.with_session do |s|
                s .tag_group[group_id] << s.oligo[new_oligo_id]
              end
              }.to change { db[:oligos].count }.by(0)
            end
          end
        end
      end

      context "created but not added to a session" do
        it "should not be saved" do
          expect do 
            store.with_session { |_| empty_group }
          end.to change{ db[:tag_groups].count }.by(0)
        end 
      end
    end
  end
end
