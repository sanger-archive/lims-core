require 'rubygems'
require 'ruby-debug'

module Lims::Core::Persistence::Sequel::Migrations
  module AddAuditTables
    def self.migration(exclude_tables={}, additional_tables_to_update=[])
      [:schema_info, :sessions, :primary_keys].each do |table|
        exclude_tables[table] = true
      end
      this = self
      Proc.new do
        next unless defined?(DB)
        table_names = []
        change do
          if additional_tables_to_update.size == 0
            # Create session table
            create_table :sessions do
              primary_key :id
              String :user
              String :backend_application_id
              String :parameters, :text => true
              boolean :success
              timestamp :start_time
              DateTime :end_time
            end
          end

          #create migration session
          self << <<-EOS
          INSERT INTO sessions(user, backend_application_id)
          VALUES('admin', 'lims-core');
          EOS

          session_id = DB[:sessions].order(:id).last[:id]

          tables_to_update = additional_tables_to_update.size == 0 ? DB.tables : additional_tables_to_update
          tables_to_update.each do |table_name|
            next if exclude_tables.include?(table_name)  
            table_names << table_name
            table = DB[table_name]

            # extend all tables with revision_id
            if DB[table].columns.include?(:revision)  == false
              alter_table table_name do             
                add_column :revision,  Integer, :default => 1
              end
            end


            # create history table
            revision_table = "#{table_name}_revision"
            self << <<-EOS
            CREATE TABLE #{revision_table} AS
            SELECT *, 'initial' AS `action`, #{session_id} as session_id
            FROM #{table_name}
            EOS

            puts "adding key to #{revision_table}"
            alter_table revision_table do
              add_primary_key :internal_id
              add_index [:id, :revision], :unique => true
              add_index [:id, :session_id], :unique => true
              add_foreign_key [:session_id], :sessions, :key => :id
            end


            # Create trigger              
            trigger_name = "maintain_#{table_name}_on_insert"
            self  << "DROP TRIGGER IF EXISTS #{trigger_name};"
            trigger_code = <<-EOT

            CREATE TRIGGER #{trigger_name}  AFTER INSERT ON  #{table_name}
            FOR EACH ROW
            BEGIN
            #{this.insert_into_revision(table, revision_table, :insert)}
            EOT

            puts trigger_code
            self << trigger_code

            trigger_name = "maintain_#{table_name}_on_update"
            self  << "DROP TRIGGER IF EXISTS #{trigger_name};"
            trigger_code = <<-EOT

            CREATE TRIGGER #{trigger_name}  BEFORE UPDATE ON  #{table_name}
            FOR EACH ROW
            BEGIN
            # Update the revision number
            SET NEW.revision = OLD.revision+1;
            # Update the revision table
            #{this.insert_into_revision(table, revision_table, :update)}
            EOT

            puts trigger_code
            self << trigger_code

            trigger_name = "maintain_#{table_name}_on_delete"
            self  << "DROP TRIGGER IF EXISTS #{trigger_name};"
            trigger_code = <<-EOT

            CREATE TRIGGER #{trigger_name}  BEFORE DELETE ON  #{table_name}
            FOR EACH ROW
            BEGIN
            #{this.insert_into_revision(table, revision_table, :delete)}
            EOT

            puts trigger_code
            self << trigger_code
          end

          if additional_tables_to_update.size > 0
            self << "DROP VIEW IF EXISTS revisions"
          end

          revision_tables = DB.tables.map { |table| table unless table.match(/revision/) }.compact
          revision_tables -= exclude_tables.keys

          view_code = "CREATE VIEW revisions AS " + revision_tables.map do |table_name|
            revision_table = "#{table_name}_revision"
            %Q{ SELECT '#{table_name}' AS revision_table,
            id,
            action,
            session_id
            FROM #{revision_table}

          }
          end.join(' UNION ')

          puts view_code
          self << view_code
        end
      end
    end

#    SET #{
#      if type == :delete
#        'id = OLD.id, revision = OLD.revision+1'
#      else
#        table.columns.map { |c| "`#{c}` = NEW.#{c}" }.join(', ')
#      end
#    }
    
    def self.insert_into_revision(table, revision_table, type)
      %Q{ INSERT INTO #{revision_table} 
      #{if type == :delete
          '(id, revision, action, session_id) VALUES (OLD.id, OLD.revision+1, #{type}, @current_session_id)'
        else
          '(' + table.columns.map { |c| "`#{c}`" }.join(', ') + ', `action`, `session_id`) VALUES(' + table.columns.map { |c| "NEW.#{c}" }.join(', ') + ", #{type}, @current_session_id)"
        end
      };
      END;
      }
    end
  end
end
