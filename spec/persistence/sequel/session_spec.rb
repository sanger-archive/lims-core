# Spec requirements
require 'persistence/sequel/spec_helper'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/persistence/sequel/session'
require 'lims-core/persistence/sequel/persistor'

module Lims::Core::Persistence
  module ForTest
    class Name
      include Lims::Core::Resource
      attribute :name, String
      class NamePersitor < Lims::Core::Persistence::Persistor
        Model = Name
      end
    end
  end

  module Sequel
    describe Session, :session => true, :persistence => true, :persistence => true, :sequel => true do
      context "with mysql underlying" do
        include_context "mysql db"
        let(:store) { Store.new(db).tap do
          db.create_table :sessions do
            primary_key :id
            String :user
            String :backend_application_id
            String :parameters, :text => true
            boolean :success
            timestamp :start_time
            DateTime :end_time
          end unless db.table_exists?(:sessions)
        end}
        it "sets a new session_id to work with" do
          begin
            my_session_id=nil
            store.with_session do |s|
              my_session_id = s.get_current_session
            end
          rescue
          end
          (my_session_id == nil).should == false
        end
        it "session is reseted after scope" do
          begin
            my_session_id=nil
            store.with_session do |s|
              my_session_id = s.get_current_session
            end
            my_session_after_scope = s.get_current_session
          rescue
          end
          (my_session_after_scope == my_session_id).should == false
          (my_session_after_scope == nil).should == true
        end
        it "a different session if I create a new scope" do
          begin
            my_session_id=nil
            my_session_id_2=nil
            store.with_session do |s|
              my_session_id = s.get_current_session
            end
            my_session_after_scope = s.get_current_session
            store.with_session do |s|
              my_session_id_2 = s.get_current_session
            end
            my_session_after_scope_2 = s.get_current_session
          rescue
          end
          (my_session_id == my_session_id_2).should == false
        end
      end

      context "with sqlite underlying" do
        include_context "sqlite db"
        let(:store) { Store.new(db).tap do
            db.create_table :primary_keys do
              primary_key :id
              String :table_name
              Integer :current_key
            end
          end
        }

        context "#transaction" do
          let(:a) { ForTest::Name.new(:name => "A") }
          let(:b) { ForTest::Name.new(:name => "B") }
          let(:c) { ForTest::Name.new(:name => "C") }

          before() do
            db.create_table :names do
              primary_key :id
              String :name
            end

            c.stub(:attributes) do
              raise RuntimeError, "Can't save '#{inspect}'"
            end
          end

          it "save the 2 if no problem" do
            expect { store.with_session do |s|
                s << a << b
              end }.to change{db[:names].count}.by(2)
          end

          it "saves 0 if the second doesn't save" do
            expect {
              begin
                store.with_session do |s|
                  s << a << c
                end
              rescue
              end
            }.to change{db[:names].count}.by(0)
          end

          xit "saves 0 if the second is not valid" do
          end
        end
      end
    end
  end
end
