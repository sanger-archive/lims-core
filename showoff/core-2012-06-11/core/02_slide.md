!SLIDE small
# Actions #
An action is a *reversible* functor:
* has parameters
* can be called
* can be reversed (if possible)

corresponding to an API call.

!SLIDE small
# Actions #
* persistence aware
* called as-is by the API server.
* can be pipeline specific.
* executed within a `Session`
* and a context (user, application).


!SLIDE small
# How to call an action

* pass context parameters (store, user, application)
* pass parameters block initializer
* call it

!SLIDE small
# Example     
	@@@ ruby
	target_id = ...
	source_id = ...
            action = PlateTransfer.new(:store => store, :user => user, :application => application) do |action, session|
	      # session needed
              action.target = session.plate[target_id]
              action.source = session.plate[source_id]

              action.transfer_map = { :C3 => :B1 }
            end 

	action.call
	

!SLIDE small
# Action design

* declare parameters (attributes)
* implement `_call_in_session` to modify/create the model
* attributes and results are automatically managed

!SLIDE small
# PlateTransfer Action
	@@@ ruby
    class PlateTransfer
      include Action

      attribute :source, Laboratory::Plate, :required => true, :writer => :private
      attribute :target, Laboratory::Plate, :required => true, :writer => :private
      attribute :transfer_map, Hash, :required => true, :writer => :private

      # transfer the content of  from source to target according to map
      def _call_in_session(session)
	  transfer_map.each do |from ,to|
	    target[to] << source[from].take
	  end
      end
    end





 
!SLIDE small
# Done

* laboratory classes needed for pulldown
* persistence on Laborotory
* SQL store and basic Persistors
* transfer action

!SLIDE small
# To do
* manage `dirty` attributes
* integration with API server
* add samples
* add study, projects
* submission, orders
* audit session
* eager loading
* bulk saving
