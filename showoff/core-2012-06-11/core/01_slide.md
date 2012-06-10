!SLIDE small
# `lims::core` #
A set of dependent components

* API : `Actions`
* Persistence : `Session`
* Domain: `Laboratoy`, `LabProcess`, `Organization`

API => Persistence => Domains.
!SLIDE small
# Principles
* Models exists without the notion of persistence
* Everything created within a `Session` is saved (at the end)
* Everything manipulating objects is done through *external* `Actions`.

!SLIDE smaller
# Foundation #
The lims::core is based on two gems

* `Datamapper2` 
	* `Virtus` - model definition
	* <span class="red">`Aequitas`</span>- validation library
* `Sequel` '*The database toolkit for ruby*'

.notes they boths provide a full active record like 

!SLIDE code
# Virtus, Aequitas #

	@@@ ruby
	class Sample
	  include Virtus
	  include Aequitas
	  attribute :name, String, :required => true
	end

	s = Sample.new
	s.valid? #=> false

!SLIDE code
# Sequel #

	@@@ ruby
	samples DB[:samples] #=> proxy

	samples.first #=> { :id  =>  1, :name => 'my sample' }

	samples_with_aliquots = samples.join(:aliquots, :sample_id => :id) => #proxy
	samples_with_aliquots.first 
		#=> { :sample_id => 1, :name => 'my sample', :id => 3)

!SLIDE smaller  
# Persistence-less model
## Plate declaration

	@@@ ruby
	class Plate
	  include Resource
	      # declare row_number and column_number
	      %w(row column).each do |w|
		attribute :"#{w}_number",  Fixnum, :required => true, :gte => 0, :writer => :private
	      end
		
		class Well
		include Resource
		...
		end

	      is_array_of Well do |p,t|
		(p.row_number*p.column_number).times.map { t.new }
	      end
	end
Plate is like an Array

!SLIDE code smaller fullpage
# Persistence-less model - Bare model
## Plate spec

	@@@ ruby
	describe Plate do
	    subject { Plate.new(:row_number => 8,
						:column_number => 12) }

	    it "can be indexed with a symbol " do
	      subject[:B3].should be_a(Plate::Well)
	      aliquot = mock(:aliquot)

	      subject[:B3] << aliquot
	      subject[:B3].should include(aliquot)
	    end
	end

Well is like an array too.


!SLIDE small
# Session

* A session is in charge of restoring and saving objects through the persistence layer.
* Every modifications within a session **block** is saved.
* Everything is saved only once.
* <span class="red">It's the only way to save an object</span>
* It provides an **IdentityMap**.

!SLIDE small
# Session 
## Benefits #

* Persistence operations not mixed with business logic code.
* Everything is automatically wrapped in a transaction.
* saves can be bulk (not implemented)
* eager loading (not implemented) can be set at session, or application level
* Session information (user, date, client) can be auditted in a `session` table

!SLIDE small
# Session #
Sessions have been designed to make some stuff hard for the developper as:

* Load and save object(s) in different sessions.
* Save an object in the middle of an *action* (method, function, ...).

If you find yourself struggling trying to do something above, you **probably **shoudn't be doing it.


!SLIDE small
# Session API #

* It groups and save all object modifactions within a block in one transaction
* Session information (user, time) are also associated to the modifications of those objects.
       A Session can not normally be created by the end user. It has to be in a Store::with_session
       block, which acts has a transaction and save/update everything at the end of it.
       It should also provides an identity map.
       Session information (user, time) are also associated to the modifications of those objects.
* Everything within a session is saved.
* everything is saved only once
* it's the only way to save an object
* save can be bulk etc

identitmapy

!SLIDE small
# Actions
# Benefit
everything within a session is saved.
everything is saved only once
save can be bulk etc


# Examples
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
