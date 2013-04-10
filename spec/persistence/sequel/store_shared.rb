
# Spec requirements
require 'spec_helper'

# Model requirements
require 'sequel'
require 'lims-core/persistence/sequel/store'
Sequel.extension :migration

shared_context "prepare tables" do
  def prepare_table(db)
    Sequel::Migrator.run(db, 'db/migrations')
  end
end

Loggers = []
#require 'logger'; Loggers << Logger.new($stdout)

shared_context "sequel store" do
    include_context "prepare tables"
    let(:db) {  Sequel.sqlite '' , :loggers => Loggers }
    let(:store) { Lims::Core::Persistence::Sequel::Store.new(db) }
    before (:each) { prepare_table(db) }

end
