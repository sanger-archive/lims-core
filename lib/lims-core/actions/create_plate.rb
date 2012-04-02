# vi: ts=2:sts=2:et:sw=2  spell:spelllang=en  
require 'lims/core/actions/action'

require 'lims/core/laboratory/plate'

module Lims::Core
  module Actions
    class CreatePlate
      include Action

      %w(row column).each do |w|
        attribute :"#{w}_number",  Fixnum, :required => true, :gte => 0, :writer => :private
      end

      def initialize(*args, &block)
        @name = "Create Plate"
          # readonly attributes are normaly not allowed in constructor
          # by Virtus. We need to call set_attributes explicitely
          options = args.extract_options!
          # we would use `options & [:row ... ]` if we could
          # but Sequel redefine Hash#& ...
          dimensions = options.subset([:row_number ,:column_number])
          set_attributes(dimensions)
          super(*args, options - dimensions, &block)
      end

      def _call_in_session(session)
        Laboratory::Plate.new(:column_number => column_number, :row_number => row_number).tap do |plate|
          session << plate
        end
      end
    end
  end
end
