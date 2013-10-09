# requirement used by  everything
require 'facets/string'
require 'facets/kernel'
require 'facets/hash'
require 'facets/array'

require 'virtus'
require 'aequitas/virtus_integration'

module Lims::Core
  module Helpers
    def self.gem_available?(gem_name)
      begin
        Gem::Specification.find_by_name(gem_name)
      rescue Gem::LoadError
        false
      end
    end

    # Load the available gem for json
    if gem_available?('jrjackson')
      require 'jrjackson'
    elsif gem_available?('oj')
      require 'oj'
    else
      require 'json'
    end

    def self.load_json(json)
      if gem_available?('jrjackson')
        JrJackson::Json.load(json)
      elsif gem_available?('oj')
        Oj.load(json)
      else
        JSON.parse(json) 
      end
    end

    def self.to_json(object)
      if gem_available?('jrjackson')
        JrJackson::Json.dump(object)
      elsif gem_available?('oj')
        Oj.dump(object, :mode => :compat)
      else
        object.to_json
      end
    end
  end
end

class Object
  def andtap(&block)
    self && (block ? block[self] : self)
  end

  def self.parent_scope()
    @__parent_scope ||= eval self.name.split('::').tap { |_| _.pop }.join('::')
  end
end
