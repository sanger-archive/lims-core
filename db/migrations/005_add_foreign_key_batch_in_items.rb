::Sequel.migration do
  change do
    alter_table(:items) do
      add_foreign_key :batch_id, :batches, :key => :id
    end
  end
end
