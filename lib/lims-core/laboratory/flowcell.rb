require 'lims/core/laboratory/receptacle'
require 'lims/core/resource'

module Lims::Core
  module Laboratory
    # A flowcell with some lanes.
    # readable labels on it.
    # TODO add label behavior
    class Flowcell
      include Resource

      attribute :number_of_lanes, Fixnum, :required => true, :gte => 0, :writer => :private

      # A lane on a {Flowcell flowcell}.
      # Contains some chemical substances.
      class Lane
        include Receptacle

        def to_s()
          content.to_s
        end
      end


      module AccessibleViaSuper
      # @todo move in class method in resource
        def initialize(*args, &block)
          # readonly attributes are normaly not allowed in constructor
          # by Virtus. We need to call set_attributes explicitely
          options = args.extract_options!
          # we would use `options & [:lane_number ]` if we could
          # but Sequel redefine Hash#& ...
          number_of_lanes = options.subset([:number_of_lanes])
          set_attributes(number_of_lanes)
          super(*args, options - number_of_lanes, &block)
        end

      end
      # We need to do that so is_array can call it via super
      include AccessibleViaSuper

      is_array_of Lane do |flowcell,t|
        flowcell.number_of_lanes.times.map { t.new }
      end

     # iterate only between non empty lanes.
     # @yield [content]
     # @return itself
     def each_content
       content.each do |content|
         yield content if content
       end
     end
    end
  end
end
