require 'common'

module Lims::Core
  module Actions
    # This class represent the base class of all actions.
    # It needs a user, and will be wrapped within a transaction/{Session}
    # It will be probably a kind of functor, i.e. all the parameters are set at initialisation.
    # Ideally it will detect all object changes and take care of the persistence.
    # Parameters will be probably wrapped in a {ArgumentProxy} enabling DCI.
    #   action = Action::Base.new(plate) do |a|
    #     a.plate # return a proxy to a plate so we can do   a.plate.action # => a
    #     ...
    #   end
    #   action.perform
    #
    # The real class of the argument proxy could be declared  like this
    #   class TransferPlate < Action 
    #     class PlateProxy < ArgumentProxy
    #     end
    #
    #     argument :source_plate, PlateProxy
    #   end
    class Action
    end
  end
end
