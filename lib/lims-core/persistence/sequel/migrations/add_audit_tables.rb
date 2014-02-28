module Lims::Core::Persistence::Sequel::Migrations
  module AddAuditTables

    def self.migration(exclude_tables=[], new_tables=[])
      # Capture the local scope to use it in the Proc
      this = self
      # Fix hash to array
      exclude_tables = exclude_tables.keys if exclude_tables.is_a?(Hash)
      exclude_tables.concat(self.non_revision_tables)

      Proc.new do
        next unless defined?(DB)

        change do
          tables_to_update = new_tables.empty? ? DB.tables : new_tables.map(&:to_sym)
          tables_to_update.delete_if { |table_name| exclude_tables.include?(table_name) }
          this.create_session_table(self) if new_tables.empty?
          session_id = this.create_migration_session(self)

          tables_to_update.each do |table_name|
            revision_table_name = "#{table_name}_revision"
            this.add_revision_id_column(self, table_name)
            this.create_revision_table(self, table_name, revision_table_name, session_id)
            this.create_trigger_on_insert(self, this, table_name, revision_table_name)
            this.create_trigger_on_update(self, this, table_name, revision_table_name)
            this.create_trigger_on_delete(self, this, table_name, revision_table_name)
          end
          
          this.drop_revision_view(self) unless new_tables.empty?
          this.create_revision_view(self, exclude_tables)
        end
      end
    end


    def self.non_revision_tables
      [:schema_info, :sessions, :primary_keys]
    end

    def self.create_session_table(sequel)
      sequel.create_table :sessions do
        primary_key :id
        String :user
        String :backend_application_id
        String :parameters, :text => true
        boolean :success
        timestamp :start_time
        DateTime :end_time
      end
    end

    def self.create_migration_session(sequel)
      sequel[:sessions].insert(:user => 'admin', :backend_application_id => 'lims-core')
    end

    def self.add_revision_id_column(sequel, table_name)
      unless DB[table_name].columns.include?(:revision)
        sequel.alter_table table_name do
          add_column :revision, Integer, :default => 1 
        end
      end
    end

    def self.create_revision_table(sequel, table_name, revision_table_name, session_id)
      sequel << %Q{
        CREATE TABLE #{revision_table_name} AS
        SELECT *, 'initial' as 'action', #{session_id} as session_id
        FROM #{table_name};
      }

      sequel.alter_table revision_table_name do
        add_primary_key :internal_id
        add_index [:id, :revision], :unique => true
        add_index [:id, :session_id], :unique => true
        add_foreign_key [:session_id], :sessions, :key => :id
      end
    end

    def self.drop_trigger(sequel, trigger_name)
      sequel << "DROP TRIGGER IF EXISTS #{trigger_name};"
    end

    def self.create_trigger_on_insert(sequel, migration_scope, table_name, revision_table_name)
      trigger_name = "maintain_#{table_name}_on_insert"        
      migration_scope.drop_trigger(sequel, trigger_name)
      sequel << %Q{
        CREATE TRIGGER #{trigger_name} AFTER INSERT ON #{table_name}
        FOR EACH ROW
        BEGIN
          #{migration_scope.insert_into_revision(table_name, revision_table_name, :insert)}          
        END;
      }
    end

    def self.create_trigger_on_update(sequel, migration_scope, table_name, revision_table_name)
      trigger_name = "maintain_#{table_name}_on_update"
      migration_scope.drop_trigger(sequel, trigger_name)

      increment_revision_sql = case DB.database_type
                               when :sqlite then "UPDATE #{table_name} SET revision = OLD.revision+1 where id=OLD.id;"
                               else "SET NEW.revision = OLD.revision+1;"
                               end

      sequel << %Q{
        CREATE TRIGGER #{trigger_name} BEFORE UPDATE ON #{table_name}
        FOR EACH ROW
        BEGIN
          #{increment_revision_sql}
          #{migration_scope.insert_into_revision(table_name, revision_table_name, :update)}
        END;
      }
    end
  
    def self.create_trigger_on_delete(sequel, migration_scope, table_name, revision_table_name)
      trigger_name = "maintain_#{table_name}_on_delete"
      migration_scope.drop_trigger(sequel, trigger_name)
      sequel << %Q{
        CREATE TRIGGER #{trigger_name} BEFORE DELETE ON #{table_name}
        FOR EACH ROW
        BEGIN
          #{migration_scope.insert_into_revision(table_name, revision_table_name, :delete)}
        END;
      }
    end

    def self.insert_into_revision(table_name, revision_table_name, type)
      fields, values = nil, nil
      table = DB[table_name]
      current_session_id = case DB.database_type
                           when :sqlite then "(SELECT id from sessions order by id desc limit 1)" 
                           else "@current_session_id"
                           end

      fields = table.columns.map { |c| "`#{c}`" } + ["action", "session_id"]
      if type.to_s == "delete"
        values = table.columns.map { |c| (c == :revision) ? "OLD.#{c}+1" : "OLD.#{c}" }          
      else
        if DB.database_type == :sqlite && type.to_s == "update"
          # With sqlite, we need to increment the revision on update
          values = table.columns.map { |c| (c == :revision) ? "NEW.#{c}+1" : "NEW.#{c}" }          
        else
          values = table.columns.map { |c| "NEW.#{c}" }
        end
      end
      values += ["'#{type}'", current_session_id]

      %Q{
      INSERT INTO #{revision_table_name} (#{fields.join(",")}) 
      VALUES (#{values.join(",")}); 
      }
    end

    def self.drop_revision_view(sequel)
      sequel << "DROP VIEW IF EXISTS revisions;"
    end

    def self.create_revision_view(sequel, exclude_tables)
      current_tables = DB.tables.reject do |table| 
        table.match(/revision/) || exclude_tables.include?(table) 
      end

      view_sql = "CREATE VIEW revisions AS "
      view_sql << current_tables.map do |table_name|
        revision_table_name = "#{table_name}_revision"
        %Q{
          SELECT '#{table_name}' 
          AS revision_table, id, action, session_id
          FROM #{revision_table_name}
        }
      end.join(' UNION ')
      sequel << view_sql
    end
  end
end
