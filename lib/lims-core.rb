# vi: spell:spelllang=en ts=2:sts=2:sw=2:et
require "lims-core/version"

require 'lims-core/actions'
require 'lims-core/laboratory'
require 'lims-core/organization'
 require 'lims-core/persistence'
# Persistence submodules need to be required manually. This is to avoid
# having to require and install all the store dependency (mysql, postgres) etc ...


# LIMS stands for Laboratory Information Management System.
# A namespace.
module Lims
  # The Core of the {Lims LIM S}ystem.
  # Includes the basic classes corresponding to the :  
  # 1. domain(s)
  # 2. Persistence Layer
  # 3. Business Logic layer (extension ?)
  #
  # The Core is split in the following submodule/namespace :
  # 1. {Laboratory} :
  #    Things used/found in the lab. Includes pure laboratory (inert things as {Laboratory::Plate plates}, {Laboratory::Tube tubes})
  #    and chemical one (as {Laboratory::Aliquot aliquots}, {Laboratory::Sample samples}).
  # 3. {LabProcess}
  #    Related to the work people/robot do in the laboratories.
  # 5. {Organization}
  #    Related to {Organization::User users}, data release ({Organization::Study studies}) and ordering ({Organization::Order orders}).
  # 10. {Actions}
  #     High level {Actions::Action actions} that can be performed on things (mostly laboratory).
  #   
  # 12. {Persistence}
  #
  #
  # This partition is more for clarity/documentation purposes and it's not meant to be really tight. 
  # However it's more likely than the submodules dependency will be a tree than a graph, (but it's not a necessity).   
  module Core
    # Your code goes here...
  end
end
