# vi: ts=2 sts=2 et sw=2 spell spelllang=en  
require 'common'
require 'lims-core/base'
require 'lims-core/subclass_tracker'

module Lims::Core
  module Resource
    extend SubclassTracker
    # We need to rename the actual self.included method
    class << self
      alias_method :tracker_included, :included
    end
    def self.included(klass)
      klass.class_eval do
        include Base
      end
      tracker_included(klass)
    end
  end
end

