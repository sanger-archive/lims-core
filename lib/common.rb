# requirement used by  everything
require 'facets/string'
require 'facets/kernel'
require 'facets/hash'
require 'facets/array'

require 'virtus'
require 'aequitas/virtus_integration'

module Lims::Core
  def self.gem_available?(gemfile)
    begin
      Gem::Specification.find_by_name(gemfile)
      true
    rescue Gem::LoadError
      false
    end
  end
end

case
when Lims::Core.gem_available?('oj')
  require 'oj'
when Lims::Core.gem_available?('jrjackson')
  require 'jrjackson'
else
  require 'json'
  alias :orig_to_json :to_json
end

class Object
  def andtap(&block)
    self && (block ? block[self] : self)
  end

  def self.parent_scope()
    @__parent_scope ||= eval self.name.split('::').tap { |_| _.pop }.join('::')
  end

  def to_json(object)
    case
    when Lims::Core.gem_available?('oj')
      Oj.dump(object)
    when Lims::Core.gem_available?('jrjackson')
      JrJackson::Json.dump(object)
    else
      object.orig_to_json
    end
  end
end
