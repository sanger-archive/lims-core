::Sequel.migration do
  up do
    create_table(:batches) do
      primary_key :id
      String :process
    end
  end

  down do
    drop_table(:batches)
  end
end
