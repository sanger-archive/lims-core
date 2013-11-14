require 'persistence/spec_helper'

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


