# Spec requirements
require 'spec_helper'

# Model requirements
require 'sequel'

shared_context "prepare tables" do
  before do
    DB = Sequel.sqlite '', :logger => Logger.new($stdout) 
    DB.create_table :aliquots do
      primary_key :id
      String :sample
      String :tag
      Integer :quantity
      String :type


      #Integer :lane_id # naive
    end

    DB.create_table :flowcells do
      primary_key :id
    end

    DB.create_table :lanes do
      #primary_key :flowcell_id, :position
      primary_key :id
      Integer :flowcell_id
      Integer :position
      Integer :aliquot_id
    end
  end
end

