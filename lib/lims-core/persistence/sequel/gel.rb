require 'lims/core/persistence/gel'
require 'lims/core/persistence/sequel/persistor'

module Lims::Core
  module Persistence
    module Sequel
      # A gel persistor. It saves the gel's data to the DB.
      class Gel < Persistence::Gel
        include Sequel::Persistor

        # A window persistor. It saves the window's data to the DB.
        class Window < Persistence::Gel::Window
          include Sequel::Persistor
          def self.table_name
            :windows
          end

          def save_raw_association(gel_id, aliquot_id, position)
              dataset.insert(:gel_id => gel_id,
                             :position => position,
                             :aliquot_id  => aliquot_id)
          end

          # Do a bulk load of aliquot and pass each to a block
          # @param gel_id the id of the gel to load.
          # @yieldparam [Integer] position
          # @yieldparam [Aliquot] aliquot
          def load_aliquots(gel_id)
            Window::dataset(@session).join(Aliquot::dataset(@session), :id => :aliquot_id).filter(:gel_id => gel_id).each do |att|
              position = att.delete(:position)
              att.delete(:id)
              aliquot  = @session.aliquot.get_or_create_single_model(att[:aliquot_id], att)
              yield(position, aliquot)
            end
          end
        end 
        #class Window

        def self.table_name
          :gels
        end

        # Delete all children of the given gel
        # But don't destroy the 'external' elements (example aliquots)
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::Gel] gel
        def delete_children(id, gel)
          Window::dataset(@session).filter(:gel_id => id).delete
        end

        # Load all children of the given gel
        # Loaded object are automatically added to the session.
        # @param [Fixnum] id the id in the database
        # @param [Laboratory::Gel] gel
        # @return [Laboratory::Gel, nil] 
        #
        def load_children(id, gel)
          window.load_aliquots(id) do |position, aliquot|
            gel[position] << aliquot
          end
        end
      end
    end
  end
end
