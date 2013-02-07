module Lims::Core
  module Actions
    module Container

      def self.included(klass)
        klass.class_eval do
          include Virtus
          include Aequitas

          %w(row column).each do |w|
            attribute :"number_of_#{w}s",  Fixnum, :required => true, :gte => 0, :writer => :private
          end
        end
      end

      def _call_in_session(session)
        newContainer = getContainer.new(:number_of_columns => number_of_columns, :number_of_rows => number_of_rows)
        session << newContainer
        element_description.each do |element_name, aliquots|
          aliquots.each do |aliquot|
            newContainer[element_name] <<  Laboratory::Aliquot.new(aliquot)
          end
        end
        { container_sym => newContainer, :uuid => session.uuid_for!(newContainer) }
      end
    end
  end
end
