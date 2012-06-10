!SLIDE small transition=scrollLeft
# Actions #
## A  *reversible* functor:

* Has parameters.
* Can be called.
* Can be reversed (when possible).

### corresponding to an API call.

!SLIDE small transition=scrollUp subsection
# Actions #
* Persistence aware
* Called as-is by the API server.
* Can be pipeline specific.
* Executed within a `Session` and
* ... a context (user, application).


!SLIDE small transition=scrollUp subsection
# Actions
## How to call an action

1. Pass context parameters (store, user, application),
2. pass a parameters initializer block,
3. call it.

!SLIDE smaller subsection transition=scrollLeft
# Actions / call
## Example     
	@@@ ruby
	target_id = ...
	source_id = ...
    action = PlateTransfer.new(:store => store,
							 :user => user,
							 :application => application
						 )  do |action, session|
	      # session needed
		  action.target = session.plate[target_id]
		  action.source = session.plate[source_id]

		  action.transfer_map = { :C3 => :B1 }
	end 

	action.call
	


!SLIDE small transition=scrollRight subsection
# Actions
## Design

* Declare parameters (attributes).
* Implement `_call_in_session` to modify/create the model.
* Attributes and results are automatically managed.

!SLIDE smaller transition=scrollUp subsection
# Actions / Design
## PlateTransfer Action
	@@@ ruby
    class PlateTransfer
      include Action

      attribute :source, Laboratory::Plate, :required => true
      attribute :target, Laboratory::Plate, :required => true
      attribute :transfer_map, Hash, :required => true

      # Transfers the content of  from source to target
      # according to a transef map.
      def _call_in_session(session)
	    transfer_map.each do |from ,to|
	      target[to] << source[from].take
	    end
	  end
    end

 
!SLIDE small transition=scrollRight
# Done

* Laboratory classes needed for pulldown.
* Persistence on Laborotory.
* SQL store and basic Persistors.
* Transfer action.

!SLIDE small transition=scrollLeft
# To do
* Manage `dirty` attributes
* Integration with API server
* Add samples
* Add study, projects
* Submission, orders

!SLIDE small transition=scrollUp subsection
# To do
## wish list

* Audit session
* Eager loading
* Bulk saving

!SLIDE transition=shuffle
# The End
Any Questions ?


