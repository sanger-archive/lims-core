# Spec requirements
require 'persistence/sequel/spec_helper'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/persistence/sequel/session'
require 'lims-core/persistence/sequel/persistor'

require 'lims-core/persistence/user_session'
require 'lims-core/persistence/sequel/migrations/add_audit_tables'

require 'lims-core/persistence/sequel/user_session_sequel_persistor'

module Lims::Core
  module Persistence
    describe Lims::Core::Persistence::UserSession do
      context "With sql test store" do
        include_context "sqlite db"
        include_context "with test store"
          before(:all) {
            Sequel::Migrations::AddAuditTables::create_session_table(db)
          }

        context "with existint row" do
            let(:user) { "user@example.com" }
              let(:backend_application_id) { "rspec" }
              let(:parameters) { '{}' }
              let(:success) { false }
              let(:parameters) { Lims::Core::Helpers::to_json({"key1" => "value1"}) }
              let(:start_time) { Time.new "2013/01/01 - 12:34:56" }
              let(:end_time) { Time.new "2013/01/01 - 13:00:00" }
          let!(:session_id) {
            db[:sessions].insert(:user => user,
              :backend_application_id => backend_application_id,
              :parameters => parameters,
              :success => success,
              :start_time => start_time,
              :end_time => end_time)
          }


          it "can be loaded" do
            store.with_session do |session|
              user_session = session.user_session[session_id]
              user_session.id.should == session_id
              user_session.user.should == user
              user_session.backend_application_id.should == backend_application_id
              user_session.parameters.should == parameters
              user_session.success.should == success
              user_session.parameters.should == parameters
              user_session.start_time.should == start_time
              user_session.end_time.should == end_time
            end
          end

          it "can't be saved" do
              expect {
                begin
                  store.with_session do |session|
                    session << UserSession.new
                  end
                rescue
                end

              }.to change { db[:sessions].count }.by(0)
            end
            it "can't be saved" do
              expect {

                store.with_session do |session|
                  session << UserSession.new
                end
              }.to raise_error Persistence::Session::ReadonlyClassException
            end
          end
        end
      end
    end
  end
