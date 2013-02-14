::Sequel.migration do
  change do
    alter_table(:items) do
      add_column :batch_uuid, String, :fixed => true, :size => 64
    end
  end
end
