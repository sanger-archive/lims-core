::Sequel.migration do
  up do
    alter_table(:orders) do
      set_column_type(:parameters, :blob)
    end
  end

  down do
    alter_table(:orders) do
      set_column_type(:parameters, :string)
    end
  end
end
