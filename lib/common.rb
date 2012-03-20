# requirement used by  everything
require 'facets/string'
require 'facets/kernel'

require 'virtus'
require 'aequitas/virtus_integration'

class Object
  def andtap(&block)
    self && (block ? block[self] : self)
  end
end

