require 'common'
require 'lims-core/resource'

module Lims::Core
  module Laboratory
    # A sample is a constituant of an aliquot.
    # It refers to a sample of DNA of an 'individual' at a particular time.
    # The core doesn't need to care about 'individual',
    # it just store metadata (like organism, gender, etc ...).
   class Sample
     include Resource
     include Aequitas
     attribute :name, String, :required => true
      def initialize(params={})
        args = {}
        case params
        when String then args[:name] = params
        when Hash then args = params
        end

        super(args)
      end

      def to_s
        @name.inspect
      end
   end
  end 
end
