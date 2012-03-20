require 'common'

module Lims::Core
  module Laboratory
    # A sample is a constituant of an aliquot.
    # It refers to a sample of DNA of an 'individual' at a particular time.
    # The core doesn't need to care about 'individual',
    # it just store metadata (like organism, gender, etc ...).
   class Sample
     include Virtus
     include Aequitas
     attribute :name, String, :required => true
   end
  end 
end
