# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'common'
require 'lims/core/resource'

module Lims::Core
  module Organization
    # A project corresponds to a source of funding.
    # It has a manager.
    class Project
      include Resource
    end
  end
end
