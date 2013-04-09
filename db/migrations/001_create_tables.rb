require 'lims-core/persistence/sequel/migrations'
Sequel.migration &Lims::Core::Persistence::Sequel::Migrations::Initial
