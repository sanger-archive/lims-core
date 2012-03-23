# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en

require 'sequel'
require 'lims/core/persistance/session'
# @todo find a way to do this automatically
require 'lims/core/persistance/sequel/flowcell'
require 'lims/core/persistance/sequel/aliquot'
require 'lims/core/persistance/sequel/plate'

module Lims::Core
  module Persistance
    module Sequel
      # Sequel specific implementation of a {Persistance::Session Session}.
      class Session < Persistance::Session
      end
    end
  end
end
