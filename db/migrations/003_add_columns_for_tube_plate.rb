::Sequel.migration do
  change do
    alter_table(:tubes) do
      add_column :type, String
      add_column :max_volume, Integer
    end

    alter_table(:plate) do
      add_column :type, String
    end
  end
end
