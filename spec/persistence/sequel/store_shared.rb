
# Spec requirements
require 'spec_helper'

# Model requirements
require 'sequel'

shared_context "prepare tables" do
  def prepare_table(db)
    db.create_table :aliquots do
      primary_key :id
      String :sample
      Integer :tag_id
      Integer :quantity
      String :type
    end

    db.create_table :flowcells do
      primary_key :id
    end

    db.create_table :lanes do
      #primary_key :flowcell_id, :position
      primary_key :id
      Integer :flowcell_id
      Integer :position
      Integer :aliquot_id
    end

    db.create_table :plates do
      primary_key :id
      Integer :row_number
      Integer :column_number
    end

    db.create_table :wells do
      primary_key :id
      Integer :plate_id
      Integer :position
      Integer :aliquot_id
    end

    db.create_table :oligos do
      primary_key :id
      String :sequence
    end

    db.create_table :tag_groups do
      primary_key :id
      String :name
    end

    db.create_table :tag_group_associations do
      primary_key :id
      Integer :tag_group_id
      Integer :position
      Integer :oligo_id
    end
    
    db.create_table :tubes do
      primary_key :id
    end

    db.create_table :tube_aliquots do
      primary_key :id
      Integer :tube_id
      Integer :aliquot_id
    end
  end
end

