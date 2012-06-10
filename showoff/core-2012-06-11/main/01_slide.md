!SLIDE top
# New LIMS Core
Maxime Bourget - Monday 2012/06/11
!SLIDE subsection transition=scrollLeft
# Overview
* what it is and why.
* How it works/design.
* What's done
* to do

!SLIDE transition=scrollUp  small subsection
# New LIMS Core
##  Set of gems, core of the new LIMS.  

* Contains the business logic, domain specific.
* Interface for different persistence layers.
* Organized in component.
* no web/GUI *knowledge*.

### Needs to be embedded in a server/application.


!SLIDE smaller subsection transition=scrollUp
# New LIMS Core
## Lessons learned from Sequencescape
### Persistence mixed with the domain implementation, adds *noise* to the code :

* domain code *aware* of persistence (`reload`, no identity map).
* domain tests have to take persistence into account (`save`, `reload`).
* object model to close from database model.
* no identity map.
* tests slow.
* hard to maintain.

.notes ActiveRecord is magic, but hard to customize and optimize.

!SLIDE small subsection transition=scrollUp
# New LIMS Core
## Goal
### Decouple domain model from persistence layer.
* code easier to split into component.
* domains of *responsibilities* clearer.
* less side effect.
* test suites small and faster.
### ...     How do we do it ?


!SLIDE small transition=scrollLeft
# New LIMS server internal architecture

*  `lims::api`  Sinatra application
* core extensions (clients specific) (optional)
* `lims:core` gem domain  model + persistence.
