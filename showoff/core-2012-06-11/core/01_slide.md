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
# Base gems #
The lims::core is based on two gems

* `Datamapper2` 
	* `Virtus` - model definition
	* <red>`Aequitas`</red>- validation library
* `Sequel` '*The database toolkit for ruby*'

.notes they boths provide a full active record like 

!SLIDE code
# Virtus #

   @@@ ruby
   class Sample
     include Virtus
     include Aequitas
     attribute :name, String, :required => true
   end

!SLIDE smaller

* rows are returned as hash.

	@@@ ruby
	DB[:samples].first
	#=> { :id  =>  1, :name => 'my sample' }

* lazy evaluation (proxy) ...

	@@@ ruby
	sample_proxy = DB[:samples]

*  and relational algebra
	sample_proxy.join(:aliquots, :sample_id => :id)


!SLIDE smaller  
# Persistence-less model - Bare model
## Plate declaration

	@@@ ruby
	class Plate
	  include Resource
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
Everything within a session is saved.
everything is saved only once
save can be bulk etc

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
