::Sequel.migration do
  up do
    create_table(:gels) do
      primary_key :id
      Integer :number_of_rows
      Integer :number_of_columns
    end

    create_table(:windows) do
      primary_key :id
      foreign_key :gel_id, :gels, :key => :id
      Integer :position
      foreign_key :aliquot_id, :aliquots, :key => :id
    end
  end

  down do
    drop_table(:windows)
    drop_table(:gels)
  end
end
