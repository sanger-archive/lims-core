# Spec requirements
require 'persistence/sequel/spec_helper'

# Model requirements
require 'lims/core/persistence/sequel/store'
require 'lims/core/persistence/sequel/session'


module Lims::Core::Persistence
  module Sequel
    describe Session do
      context "with sqlite underlying" do
        let(:store) { PS::Store.new(::Sequel.sqlite('')) }
      end
    end
  end
end
