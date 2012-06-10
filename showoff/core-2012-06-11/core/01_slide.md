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
## Purpose ##
Sessions have been designed to make some stuff hard for the developper as:

* Load and save object(s) in different sessions.
* Save an object in the middle of an *action* (method, function, ...).
* User can't create a Session without a store

If you find yourself struggling trying to do something above, you **probably **shoudn't be doing it.



!SLIDE code
# Session #

	@@@ ruby
	source_id = ...
	store.with_session(params) do |s| # Session can't be created on its own
		# load a plate, aut
		source_plate = s.plate[source_id]

		# create a new plate and add it to the session
		s << target_plate= L::Plate.new(plate.attributes)

		# transfer from one well to the another well
		@ modifies BOTH plate
		target_plate[:A1] << source_plate[:C3].take(0.5)
			
	end # save source and target


!SLIDE small
# Session API

* session needs to be created from a store :  
  `store.with_session { |s| .... }`
* tells a session to manage an object :  
  ` session << object_to_manage`
* load a object :  
  `session.plate[plate_id]`
* get the id of an object  :  
 `session.id_for_object(plate)`

!SLIDE small
# Object no managed are not saved

The following code save only one plate.

	@@@ ruby
	store.with_session do |s|
		plate1 = new_plate
		s << plate2=new_plate
	end 

!SLIDE small
# Object loaded are automatically managed

	@@@ ruby
	store.with_session do |s|
		plate = s.plate[plate_id]
		s << plate # unnecessary
	end

!SLIDE small
# Post save block
Objects are saved at the end of a `with_session` block, but ids of new object are only avavailable after the block, when the session doesn't exist anymore

	@@@ ruby
	store.with_session do |s|
		s << new_plate = Plate.new(params)
		{:new_plate => s.id_for(new_plate)}.to_json
	end


Doesn't work

!SLIDE small
# returning the session ...

	@@@ ruby
	session, new_plate = store.with_session do |s|
		s << new_plate = Plate.new(params)
		s, new_plate
	end

	{:new_plate => session.id_for(new_plate}.to_json

Would probably work, but splits the block in 2 different places. Probably one of the thing that's session has been to designed to make hard. 


!SLIDE small
# Using a lambda

	@@@ ruby
	store.with_session  do |s|
		s << new_plate = Plate.new(params)
		lambda { {:new_plate => .id_for(new_plate)}.to_json }
	end.call

Better, all the code is inside one block and the `lambda` is saying 'I am a future statement'.

Note the `call` at the end.
!SLIDE small


# Different type of stores


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
