# This module should not be require on it's own.
# Require migrations instead.

module Lims::Core::Persistence::Sequel::Migrations
  Initial = Proc.new do
    change do
      create_table :samples do
        primary_key :id
        String :name
      end

      create_table :oligos do
        primary_key :id
        String :sequence
      end

      create_table :aliquots do
        primary_key :id
        foreign_key :sample_id, :samples, :key => :id
        foreign_key :tag_id, :oligos, :key => :id
        Integer :quantity
        String :type
      end

      create_table :flowcells do
        primary_key :id
        Integer :number_of_lanes
      end

      create_table :lanes do
        #primary_key :flowcell_id, :position
        primary_key :id
        foreign_key :flowcell_id, :flowcells, :key => :id
        Integer :position
        foreign_key :aliquot_id, :aliquots, :key => :id
      end

      create_table :tubes do
        primary_key :id
      end

      create_table :tube_aliquots do
        primary_key :id
        Integer :tube_id
        foreign_key :aliquot_id, :aliquots, :key => :id
      end


      create_table :plates do
        primary_key :id
        Integer :number_of_rows
        Integer :number_of_columns
      end

      create_table :wells do
        primary_key :id
        foreign_key :plate_id, :plates, :key => :id
        Integer :position
        foreign_key :aliquot_id, :aliquots, :key => :id
      end

      create_table :tube_racks do
        primary_key :id
        Integer :number_of_rows
        Integer :number_of_columns
      end

      create_table :tube_rack_slots do
        primary_key :id
        foreign_key :tube_rack_id, :tube_racks, :key => :id
        Integer :position
        foreign_key :tube_id, :tubes, :key=> :id
      end

      create_table :tag_groups do
        primary_key :id
        String :name
      end

      create_table :tag_group_associations do
        primary_key :id
        foreign_key :tag_group_id, :tag_groups, :key => :id
        Integer :position
        foreign_key :oligo_id, :oligos, :key => :id
      end

      create_table :uuid_resources do
        primary_key :id
        String :uuid, :fixed => true, :size => 64
        String :model_class
        Integer :key
      end

      create_table :users do
        primary_key :id
      end

      create_table :studies do
        primary_key :id
      end

      create_table :orders do
        primary_key :id
        foreign_key :creator_id, :users, :key => :id

        String :pipeline
        String :parameters
        String :status
        Text :state
        foreign_key :study_id, :studies, :key => :id
        String :cost_code
      end

      create_table :items do
        primary_key :id
        foreign_key :order_id, :orders, :key => :id
        String :role
        foreign_key :resource_id, :uuid_resources, :key => :id
        String :uuid, :fixed => true, :size => 64
        String :status
        Integer :iteration, :default => 0
      end

      create_table :searches do
        primary_key :id
        String :description
        String :filter_type
        String :model
        Text :filter_parameters
      end

      create_table :labellables do
        primary_key :id
        String :name
        String :type
      end

      create_table :labels do
        primary_key :id
        foreign_key :labellable_id, :labellables, :key => :id
        String :type
        String :position
        String :value
      end
    end
  end
end
