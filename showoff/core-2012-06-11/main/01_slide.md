!SLIDE top
# New LIMS Core
Maxime Bourget - Monday 2012/06/11
!SLIDE subsection transition=scrollLeft
# Overview
* What it is and why.
* How it works/design.
* What's done
* To do

!SLIDE transition=scrollUp  small subsection
# New LIMS Core
##  Set of gems, core of the new LIMS.  

* Contains the business logic, domain specific.
* Interface for different persistence layers.
* Organized in component.
* No web/GUI *knowledge*.

### Needs to be embedded in a server/application.


!SLIDE smaller subsection transition=scrollUp
# New LIMS Core
## Lessons learned from Sequencescape
### Persistence mixed with the domain implementation, adds *noise* to the code :

* Domain code *aware* of persistence (`reload`, no identity map).
* Domain tests have to take persistence into account (`save`, `reload`).
* Object model to close from database model.
* No identity map.
* Tests slow.
* Hard to maintain.

.notes ActiveRecord is magic, but hard to customize and optimize.

!SLIDE small subsection transition=scrollUp
# New LIMS Core
## Goal
### Decouple domain model from persistence layer.
* Code easier to split into component.
* Domains of *responsibilities* clearer.
* Less side effect.
* Test suites small and faster.
### ...     How do we do it ?


!SLIDE small transition=scrollLeft
# New LIMS server internal architecture

*  `lims::api`  Sinatra application
* Core extensions (clients specific) (optional)
* `lims:core` gem domain  model + persistence.
