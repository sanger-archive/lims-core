require 'common'

# A namespace containing migrations mixin
module Lims
  module Core
    module Persistence
      module Sequel
        module Migrations
        end
      end
    end
  end
end
require_all('migrations/*') 
