# vi: ts=2 sts=2 et sw=2 spell spelllang=en  
# This module allows a class or module to track
# all of its descendants, i.e. being able to iterate
# all over all subclasses (submodules) of the tracking class.
# To do so, just include the following in the tracking class/module
# then call ::subclasses.
#

require 'lims-core'
module Lims::Core
  module SubclassTracker
    def self.extended(klass)
      (class <<klass; self; end).send :attr_accessor, :subclasses
      (class <<klass; self; end).send :define_method, :inherited do |subclass|
        klass.subclasses << subclass
        super(subclass)
      end
      (class <<klass; self; end).send :define_method, :included do |submodule|
      klass.subclasses << submodule
      (class <<submodule; self; end).send :define_method, :inherited do |subclass|
          klass.subclasses << subclass
          super(subclass)
        end
        super(submodule)
      end
      klass.subclasses = []
    end
  end
end
