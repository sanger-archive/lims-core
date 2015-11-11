require 'persistence/spec_helper'
require 'yaml'
require 'sequel'

module Helper
def save(object)
  store.with_session do |session|
    session << object
    lambda { session.id_for(object) }
  end.call
end
end

RSpec.configure do |c|
  c.include Helper
end

if RUBY_PLATFORM == "java"
  require 'jdbc/sqlite3'
  shared_context "sqlite db" do |&block|
    let(:db) { ::Sequel.connect('jdbc:sqlite::memory:') }
  end
else
  shared_context "sqlite db" do
    let!(:db) { ::Sequel.sqlite('') }
  end
end

config_database = YAML.load_file(File.join("config", "database.yml"))
ENV["LIMS_SUPPORT_ENV"] = "development" unless ENV["LIMS_SUPPORT_ENV"]
env = ENV["LIMS_SUPPORT_ENV"]
connection_params = config_database['test_mysql']

shared_context "mysql db" do |&block|
  let!(:db) { ::Sequel.connect(connection_params) }
  let(:store) { Lims::Core::Persistence::Sequel::Store.new(db) }
end


