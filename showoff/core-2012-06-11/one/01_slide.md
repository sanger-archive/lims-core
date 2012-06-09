# New Lims core presentation
* what and why
* how it works/design
* done
* to do

# LIMS Core
* Set of gems, core of the new LIMS.  
* Contains the business logic, domain specific.
* Interface for different persistence layers.
* Organized in component.
* no web/GUI *knowledge*.

Needs to be embeded in a server/application.

# Lessons learned from Sequencescape
* Persistence mixed with the domain implementation, adding *noise* in the code :
	* domain code *aware* of persistence (`reload`, no identity map).
	* domain tests have to take persistence into account (`save`, `reload`).
	* tests slow.
	* hard to maintain.

.notes ActiveRecord is magic, but hard to customize and optimize.

# Goal
* Decouple domain model from persistence layer.
	* code easier to split into component.
	* domains of *responsabilites* clearer.
	* less side effect.
	* test suites smaller and faster.
* Don't use ActiveRecord
* but ...
*     how do we do it ?


# New LIMS server internal architecture
(from client POV)
* clients specific server
*  `lims::api`  bridge between  client and core
* core extensions (clients specific)
* `lims:core`

* Can be seen as a set of depedent gems
# New Lims server Architecture

# difference


# New lims General Architecture
.notes should we explain first, the decomposition, yes
## hello ##

* Why
Replace 
* What
A gem to perform action on persistent object, meant to be used the the lims-api
* How
* Where
pulldown prototype
# Architecture #

* Architecture
- lims::core a Gem
- lims::core extension Gem (to do)
- lims::api sinatra application using core and core extension

*  New core, difference from old S
* what was bad with Rails
persistence part of the model, can't do anything without
not a problem on its own but
some bit of code needs to be persistence-aware
rails is slow, no control

tests takes a while and hard to manage

(look for code) needs of reload (add noise to the code, bug prone)
no identity map, plate.wells[0].plate != plate
test needs reload too, even when testing basic model  (reload again)
everything above add noise to the code and is bug prone.
hard to test


allow stuff to be split
If needed the persistency and the actions could be separate gems
allowing to test only what is needed, easier to maintain and faster to run

# Core architecture

API => the server
Core extension (pipeline specific)
Actions Persistence
Models


* with the new one we can
have a persistent less model.
easier to code and test

everything within a session is saved.
everything is saved only once
save can be bulk etc

eager loading parameter could be potentialy set at session level (session params)

* explain concept of session
benefit, can add tracking in a audit table

* control
the user can't save object directly
monadic way

* show lambda tip


* example of use of a logger-session


** Project structure
** How persistence work

with Persistor and Sequel::Persistor (even with subgeneration)


# concept of actions


# why sequel # why virtus
* hel
	+ 1
	+ 2
* lo
