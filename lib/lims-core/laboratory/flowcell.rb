require 'lims/core/laboratory/container'
require 'lims/core/resource'

module Lims::Core
  module Laboratory
    # A flowcell with some lanes.
    # readable labels on it.
    # TODO add label behavior
    class Flowcell
      include Resource

      # A lane on a {Flowcell flowcell}.
      # Contains some chemical substances.
      class Lane
        include Receptacle

        def to_s()
          content.to_s
        end
      end

      is_array_of Lane do |f,t|
        8.times.map { t.new }
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
