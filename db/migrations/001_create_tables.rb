Sequel.migration do
  change do
    create_table :aliquots do
      primary_key :id
      String :sample
      Integer :tag_id
      Integer :quantity
      String :type
    end

    create_table :flowcells do
      primary_key :id
    end

    create_table :lanes do
      #primary_key :flowcell_id, :position
      primary_key :id
      Integer :flowcell_id
      Integer :position
      Integer :aliquot_id
    end

    create_table :plates do
      primary_key :id
      Integer :row_number
      Integer :column_number
    end

    create_table :wells do
      primary_key :id
      Integer :plate_id
      Integer :position
      Integer :aliquot_id
    end

    create_table :oligos do
      primary_key :id
      String :sequence
    end

    create_table :tag_groups do
      primary_key :id
      String :name
    end

    create_table :tag_group_associations do
      primary_key :id
      Integer :tag_group_id
      Integer :position
      Integer :oligo_id
    end

    create_table :tubes do
      primary_key :id
    end

    create_table :tube_aliquots do
      primary_key :id
      Integer :tube_id
      Integer :aliquot_id
    end

    create_table :uuid_resources do
      primary_key :id
      Bignum :uuid
      String :model_class
      Integer :key

    end
  end
end
