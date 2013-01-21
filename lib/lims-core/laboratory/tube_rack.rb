require 'lims/core/resource'
require 'lims/core/container'

module Lims::Core
  module Laboratory
    class TubeRack
      include Resource
      %w(row column).each do |w|
        attribute :"number_of_#{w}s", Fixnum, :required => true, :gte => 0, :writer => :private, :initializable => true
      end

      is_array_of Tube
      include Container
    end
  end
end
