# vi: ts=2 sts=2 et sw=2 spell spelllang=en  
require 'common'
require 'lims-core/base'

module Lims::Core
  module Resource
    def self.included(klass)
      klass.class_eval do
        include Base
      end
    end
  end
end

