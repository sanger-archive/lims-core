require 'lims/core/actions/action'

require 'lims/core/laboratory/gel'

module Lims::Core
  module Actions
    class CreateGel
      include Action

      %w(row column).each do |w|
        attribute :"number_of_#{w}s",  Fixnum, :required => true, :gte => 0, :writer => :private
      end
      # @attribute [Hash<String, Array<Hash>>] windows_description
      # @example
      #   { "A1" => [{ :sample => s1, :quantity => 2}, {:sample => s2}] }
      attribute :windows_description, Hash, :default => {}

      def _call_in_session(session)
        gel = Laboratory::Gel.new(:number_of_columns => number_of_columns, :number_of_rows => number_of_rows)
        session << gel
        windows_description.each do |window_name, aliquots|
          aliquots.each do |aliquot|
            gel[window_name] <<  Laboratory::Aliquot.new(aliquot)
          end
        end
        { :gel => gel, :uuid => session.uuid_for!(gel) }
      end
    end
  end
  module Laboratory
    class Gel
      Create = Actions::CreateGel
    end
  end
end
