
# Spec requirements
require 'spec_helper'

# Model requirements
require 'sequel'
Sequel.extension :migration

shared_context "prepare tables" do
  def prepare_table(db)
    Sequel::Migrator.run(db, 'db/migrations')
  end
end

