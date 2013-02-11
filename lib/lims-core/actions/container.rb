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

      # The specific container should implement this method
      # and return the proper container class
      # i. e. : Laboratory::Gel
      def container_class
        raise NotImplementedError
      end

      # The specific container should implement this method
      # and return the property name of specific container's element
      # i. e. : windows_description
      def element_description
        raise NotImplementedError
      end

      # The specific container should implement this method
      # and return the container name
      # i. e. : "gel"
      def container_symbol
        raise NotImplementedError
      end

      def _call_in_session(session)
        new_container = container_class.new(:number_of_columns => number_of_columns, :number_of_rows => number_of_rows)
        session << new_container
        element_description.each do |element_name, aliquots|
          aliquots.each do |aliquot|
            new_container[element_name] <<  Laboratory::Aliquot.new(aliquot)
          end
        end
        { container_symbol => new_container, :uuid => session.uuid_for!(new_container) }
      end
    end
  end
end
