require 'persistence/spec_helper'

module Helper
def save(object)
  store.with_session do |session|
    session << object
    lambda { session.id_for(object) }
  end.call 
end
end

RSpec.configure do |c|
  c.include Helper
end


