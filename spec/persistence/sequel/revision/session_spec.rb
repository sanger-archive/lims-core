require 'persistence/sequel/revision/spec_helper'

require 'lims-core/persistence/user_session'
require 'lims-core/persistence/sequel/user_session_sequel_persistor'


module Lims::Core
  module Persistence
    module Sequel
      describe  Revision::Session do
        context "With sql test store" do
          include_context "sqlite db"
          include_context "with test store"

          let(:session_id) { 1 }
          subject { described_class.new(store, session_id)  }
          it "creates revision persistors" do
            subject.name.is_a?(Sequel::Persistor).should == true
            subject.name.is_a?(Sequel::Revision::Persistor).should == true
          end

          context "with object history" do
            before(:all) {
              # Create history table
              store.database.create_table :names_revision do
                primary_key :id
                String :name
                Integer :revision
                String :action
                Integer :session_id
                Integer :internal_id
              end

              store.database[:names_revision].multi_insert([
                  {"session_id" => 1, "internal_id" => 1, "name" => "a", "revision" => 1, "action" => "insert" },
                  {"session_id" => 5, "internal_id" => 1, "name" => "b",  "revision" => 2, "action" => "update" },
                  {"session_id" => 10, "internal_id" => 1, "name" => nil, "revision" => 3, "action" => "delete" },
                  {"session_id" => 5, "internal_id" => 2, "name" => "foo", "revision" => 1, "action" => "insert" },

                ])

            }

            def for_session(session_id)
              described_class.new(store, session_id).with_session do |session|
                yield session
              end
              
            end

            it "can read specific revision" do
              for_session(1) { |session| session.name[1].name.should == "a" }
              for_session(5) { |session| session.name[1].name.should == "b" }
              for_session(10) { |session| session.name[1].should == nil }
            end
            
            it "can read a greater revision" do
              for_session(4) { |session| session.name[1].name.should == "a" }
              for_session(6) { |session| session.name[1].name.should == "b" }
              for_session(20) do |session| session.name[1].should == nil 
                session.name.revision_for(1).action.should == "delete"
              end
            end

            it "can read in bulk" do
              for_session(6) do |session|
                names = session.name[[1, 2]] 
                names.size.should == 2
                names.map { |n| n.name}.should == ["b", "foo"]
              end
              for_session(1) do |session|
                names = session.name[[1, 2]] 
                names.size.should == 2
                names.map { |n| n && n.name }.should == ["a", nil] 
              end
            end
          end
        end
      end
    end
  end
end
