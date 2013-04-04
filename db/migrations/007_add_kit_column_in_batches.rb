::Sequel.migration do
  change do
    alter_table(:batches) do
      add_column :kit, String
    end
  end
end
