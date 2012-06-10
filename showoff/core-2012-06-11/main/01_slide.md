!SLIDE small
# New Lims core presentation
* what and why
* how it works/design
* done
* to do

!SLIDE small
# LIMS Core
 Set of gems, core of the new LIMS.  

* Contains the business logic, domain specific.
* Interface for different persistence layers.
* Organized in component.
* no web/GUI *knowledge*.

Needs to be embeded in a server/application.

!SLIDE small
# Lessons learned from Sequencescape
Persistence mixed with the domain implementation, adding *noise* in the code :

* domain code *aware* of persistence (`reload`, no identity map).
* domain tests have to take persistence into account (`save`, `reload`).
* object model to close from database model
* tests slow.
* hard to maintain.

.notes ActiveRecord is magic, but hard to customize and optimize.

!SLIDE small
# Goal
* Decouple domain model from persistence layer.
	* code easier to split into component.
	* domains of *responsabilites* clearer.
	* less side effect.
	* test suites small and faster.
* but ...     how do we do it ?


!SLIDE small
# New LIMS server internal architecture

*  `lims::api`  sinatra application
* core extensions (clients specific) (optional)
* `lims:core` gem domain  model + persistence.
