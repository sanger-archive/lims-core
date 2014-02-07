require 'persistence/spec_helper'
require 'logger'
require 'yaml'
Loggers = []
#Loggers << Logger.new($stdout)


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
    let(:db) { ::Sequel.connect('jdbc:sqlite::memory:', :loggers => Loggers) }
  end
else
  shared_context "sqlite db" do
    let!(:db) { ::Sequel.sqlite('', :loggers => Loggers) }
  end
end

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/persistence/sequel/session'
require 'lims-core/persistence/sequel/persistor'

require 'lims-core/persistence/persistable_trait'

# Dummy class
module Lims::Core::Persistence
  module ForTest
    class Name
      include Lims::Core::Resource
      attribute :name, String
      class NamePersitor < Lims::Core::Persistence::Persistor
        Model = Name
      end
    end

    # Other Dummy class with an association
    class User
      include Lims::Core::Resource
      attribute :name, Name
      attribute :email, String

      does "lims/core/persistence/persistable", :parents => [:name]
    end
  end


  shared_context "with test store" do
    let!(:store) { Sequel::Store.new(db).tap do 
        db.create_table :primary_keys do
          primary_key :id
          String :table_name
          Integer :current_key
        end

        db.create_table :names do
          primary_key :id
          String :name
        end
      end
    }
  end


end
